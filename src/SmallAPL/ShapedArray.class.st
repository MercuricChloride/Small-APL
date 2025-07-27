Class {
	#name : #ShapedArray,
	#superclass : #Object,
	#instVars : [
		'shape',
		'data'
	],
	#category : #'SmallAPL-Dumb - Arrays'
}

{ #category : #'as yet unclassified' }
ShapedArray class >> allSameSize: aCollection [
	|size|
	size := nil.
	aCollection do: [:e |
		(e isCollection or: [ e isKindOf: ShapedArray ]) ifFalse: [ ^ false ].
		size ifNil: [ size := e size ].
		e size = size
			ifFalse: [ ^ false]
	].
	^ true
]

{ #category : #'instance creation' }
ShapedArray class >> dims: dimensions data: data [
	^ self new
		shape: (ArrayShape dims: dimensions);
		data: data
]

{ #category : #'as yet unclassified' }
ShapedArray class >> from: aCollection [
	(aCollection isKindOf: self) ifTrue: [ ^ aCollection ].

	^ aCollection isCollection
		ifTrue: [ (self fromCollection: aCollection)
				bind: [ :dims :data | ^ self dims: dims data: data ] ]
		ifFalse: [ aCollection enclose ]
]

{ #category : #'as yet unclassified' }
ShapedArray class >> fromCollection: aCollection [
	|dims data|
	((self isUniform: aCollection) and: [self allSameSize: aCollection ])
		ifTrue: [
			|nested|
			(aCollection anyOne isKindOf: ShapedArray)
				ifTrue: [
					dims := {aCollection size}.
					dims := dims , (aCollection anyOne dims).
					data := (aCollection flatCollect: [:e | e cellsRank: 0 ]).
					^ {dims. data}
				].
			dims := {aCollection size}. "first part of dim"
			nested := aCollection collect: [:col | self fromCollection: col ].
			data := (nested collect: #second).
			dims := dims , (nested anyOne first).
		]
		ifFalse: [
			dims := {aCollection size}.
			data := aCollection.
		].
	^ {dims. data}
]

{ #category : #'instance creation' }
ShapedArray class >> iota: dims [
	| count |
	dims isCollection not ifTrue: [ ^ self iota: {dims} ].
	count := dims inject: 1 into: #*.
	^ self dims: dims data: (1 to: count)
]

{ #category : #'as yet unclassified' }
ShapedArray class >> isNested: aCollection [
	^ (self isUniform: aCollection) and: [aCollection anyOne isCollection]
]

{ #category : #'as yet unclassified' }
ShapedArray class >> isUniform: aCollection [
	| sample |
	aCollection ifEmpty: [ ^ false ].
	sample := aCollection first.
	^ aCollection allSatisfy: [ :e | e isKindOf: sample class ]
]

{ #category : #'instance creation' }
ShapedArray class >> unit [
	^ self new
		shape: (ArrayShape dims: #());
		data: {}
]

{ #category : #'instance creation' }
ShapedArray class >> unit: aValue [
	^ self new
		shape: (ArrayShape dims: #(1));
		data: (aValue isCollection ifTrue: [ aValue ] ifFalse: [ {aValue} ])
]

{ #category : #'api - element operations' }
ShapedArray >> * anArray [
	^ self with: anArray do: [:l :r | l * r]
]

{ #category : #'api - element operations' }
ShapedArray >> + anArray [
	^ self with: anArray do: [:l :r | l + r]
]

{ #category : #'api - alias' }
ShapedArray >> , anArray [
	"alias for concat:"
	^ self concat: anArray
]

{ #category : #'api - alias' }
ShapedArray >> /-> aBlock [
	"alias for scan:"
	^ self scan: aBlock
]

{ #category : #'api - alias' }
ShapedArray >> /> aBlock [
	"alias for reduce:"
	"The slash makes it look like it's going down a level, which is what reduce does"
	"If aBlock is an array like: {value. block}, value will be passed in as the initial value"
	^ (aBlock isCollection and: [(aBlock isKindOf: Symbol) not])
		ifTrue: [ aBlock bind: [:init :block | ^ self reduce: init using: block ] ]
		ifFalse: [ self reduce: 0 using: aBlock]
]

{ #category : #'api - alias' }
ShapedArray >> <> aRank [
	"alias for cellsRank:"
	"supposed to look like a box kinda, because we grab a particular sub-shape of the array"
	^ self cellsRank: aRank
]

{ #category : #equality }
ShapedArray >> = arr [
	self hash = arr hash ifTrue: [ ^ true ].
	(arr isKindOf: ShapedArray) ifFalse: [ ^ self = (ShapedArray from: arr) ].
	self rank = arr rank ifFalse: [ ^ false ].
	self dims = arr dims ifFalse: [ ^ false ].	"
	"
	self depth = arr depth ifFalse: [ ^ false ].
	(self cellsRank: 0)
		with: (arr cellsRank: 0)
		do: [ :l :r | l = r ifFalse: [ ^ false ] ].
	^ true
]

{ #category : #'api - alias' }
ShapedArray >> ?> aBlock [
	"alias for filter:"
	^ self filter: aBlock
]

{ #category : #'api - alias' }
ShapedArray >> @ index [
	^ self at: index
]

{ #category : #reshaping }
ShapedArray >> addToStream: stream [
	self rank = 1
		ifTrue: [
			stream nextPutAll: self data.
		]
		ifFalse: [
			self cells do: [:cell |
				(cell addToStream: stream)
			]
		].
]

{ #category : #'view - grid' }
ShapedArray >> asHorizontal [
	^ self asHorizontal: 1
]

{ #category : #'view - grid' }
ShapedArray >> asHorizontal: depth [
	| e bg |
	depth = 7
		ifTrue: [ ^ BlElement new
			size: 50@50;
			background: (NordColors aurora: 3)].
	bg := BlLinearGradientPaint horizontal
			stops: {0.0 -> (NordColors frost: 2).
					0.7 -> (NordColors polarNight: 4).
					1.0 -> (NordColors polarNight: 1)};
			yourself.
	e := BrHorizontalGrid new
			border: (BlBorder paint: (self borderPaint) width: 2);
			columnCount: self tally;
			cellSpacing: 10;
			background: bg;
			fitContent.	"((NordColors frost: 3) alpha: 0.1 * depth);"
	depth ~= 1 ifTrue: [ depth ~= 1 ifTrue: [ self onClick: e spawn: self ] ].
	e
		addChildren: (self isString
				ifTrue: [ {self scalarElement: (String newFromArray: data) depth: depth + 1} ]
				ifFalse: [ data
				collectWithIndex: [ :child :index | 
					self
						element: (child rank = 0
								ifTrue: [ self scalarElement: child depth: depth + 1 ]
								ifFalse: [ child asVertical: depth + 1 ])
						index: index ]]).	"self indexArrow: e vertical: false."
	^ e
]

{ #category : #'view - grid' }
ShapedArray >> asVertical [
	^ self asVertical: 1
]

{ #category : #'view - grid' }
ShapedArray >> asVertical: depth [
	| e bg |
	depth = 7
		ifTrue: [ ^ BlElement new
			size: 50@50;
			background: (NordColors aurora: 3)].
	bg := BlLinearGradientPaint vertical
			stops: {0.0 -> (NordColors frost: 2).
					0.7 -> (NordColors polarNight: 4).
					1.0 -> (NordColors polarNight: 1)};
			yourself.
	e := BrHorizontalGrid new
			columnCount: 1;
			cellSpacing: 10;
			border: (BlBorder paint: self borderPaint width: 2);
			background: bg;
			fitContent.
	depth ~= 1 ifTrue: [ depth ~= 1 ifTrue: [ self onClick: e spawn: self ] ].
	e
		addChildren: (self isString
				ifTrue: [ {self scalarElement: (String newFromArray: data) depth: depth + 1} ]
				ifFalse: [ data
						collectWithIndex: [ :child :index | 
							self
								element: (child rank = 0
										ifTrue: [ self scalarElement: child depth: depth + 1 ]
										ifFalse: [ child asHorizontal: depth + 1 ])
								index: index ] ]).	"self indexArrow: e vertical: true."
	^ e
]

{ #category : #'api - assertions' }
ShapedArray >> assertCommonFrame: anArray [
	(self validateCommonFrame: anArray asShapedArray)
		ifFalse: [ self rankError: anArray ]
]

{ #category : #accessing }
ShapedArray >> at: indexes [
	|idx rest|
	indexes isCollection
		ifFalse: [ ^ self at: {indexes} ].
	idx := self isSingleton
		ifTrue: [ 1 ]
		ifFalse: [ indexes first ].
	rest := indexes allButFirst.
	
	^ rest isEmpty
		ifTrue: [ self cells at: idx ifAbsent: [ self fill] ]
		ifFalse: [
			(self cells at: idx) at: rest
		]
]

{ #category : #'view - grid' }
ShapedArray >> borderPaint [
	^ BlRadialGradientPaint new
		stops: {0 -> (Color red alpha: 0.5).
				1 -> (Color blue alpha: 0.5)};
		center: 0 @ 0;
		radius: 200
]

{ #category : #'api - iteration' }
ShapedArray >> cells [
	"Returns an array of cells of rank: (self rank - 1)"
	^ self data
]

{ #category : #'api - cells' }
ShapedArray >> cellsRank: rank [
	|stream|
	self rank < rank
		ifTrue: [ ^ ShapedArray from: { self cellsRank: rank - 1 } ].
	
	self rank = rank
		ifTrue: [ ^ self ].

	stream := WriteStream on: (OrderedCollection new).
	
	self cellsRank: rank on: stream.
	
	^ ShapedArray from: (stream contents)
]

{ #category : #'private - cells' }
ShapedArray >> cellsRank: rank on: stream [
	self rank = rank
		ifTrue: [ ^ stream nextPut: self ].
	self rank = (rank + 1)
		ifTrue: [ ^ stream nextPutAll: self data ].
	
	^ self cells do: [:cell | cell cellsRank: rank on: stream ].
]

{ #category : #'api - shape' }
ShapedArray >> cols [
	self dims size = 1
		ifTrue: [ ^ self dims first ].
	^ self dims second
]

{ #category : #'private - shape' }
ShapedArray >> commonFrame: anArray [
	|max|
	anArray isShaped
		ifFalse: [ ^ self commonFrame: anArray asShapedArray ].
	max := {self rank. anArray rank} max.
	self validateCommonFrame: anArray max: max.
	^ (self shape padTo: max) sizes with: (anArray shape padTo: max) sizes collect: [:l :r |
		{l. r} max
	]
]

{ #category : #'api - concat' }
ShapedArray >> concat: anArray [
	| newData |
	anArray rank > self rank
		ifTrue: [ ^ anArray concat: self ]. "make self rank always higher or eq"
	
	anArray isShaped ifFalse: [ ^ self concat: anArray asShapedArray ].
	anArray rank = 0 ifTrue: [ ^ self ].
	(self rank = 1 and: [ anArray rank = 1 ])
		ifTrue: [ ^ (self data , anArray data) asShapedArray ].
		
	({self dims. anArray dims}
		collect: [:e | e last: (self rank - 1)])
		bind: [:l :r |
			l = r "trailing dims up tho the first dim must match"
				ifFalse: [ ^ self rankError: anArray ].
		].
	
	newData := OrderedCollection new.
	newData addAll: self data.
	anArray rank = self rank
		ifTrue: [ newData addAll: anArray data ]
		ifFalse: [ newData addAll: {anArray data} asShapedArray ].
	^ newData asShapedArray
]

{ #category : #'api - concat' }
ShapedArray >> concatFrame: anArray [
	^ (self commonFrame: anArray) allButFirst
]

{ #category : #accessing }
ShapedArray >> data [
	^ data
]

{ #category : #accessing }
ShapedArray >> data: anObject [
	data := anObject.
	data ifNotNil: [ self onDataSet ].
]

{ #category : #'api - shape' }
ShapedArray >> depth [
	self data isEmpty ifTrue: [ ^ 0 ].
	^ (self cells max: [:e | e depth]) + 1
]

{ #category : #'api - shape' }
ShapedArray >> dims [
	|dims|
	dims := self shape sizes.
	^ dims
]

{ #category : #'api - iteration' }
ShapedArray >> do: aBlock [
	^ self data withIndexDo: [:e :i | aBlock valueWithPossibleArguments: {e. i} ]
]

{ #category : #'view - grid' }
ShapedArray >> element: element index: index [
	|container label|
	container := BrVerticalFlow new
		fitContent.
	label := BrLabel new
		aptitude: (BrLabelAptitude new
			italic;
			fontSize: 9;
			bold;
			underline);
		text: (index asString asRopedText
			foreground: (NordColors snowStorm: 1);
			background: (NordColors polarNight: 1)).
		
	container addChildren: {label. element}.
	^ container
]

{ #category : #reshaping }
ShapedArray >> enclose [
	^ self
]

{ #category : #equality }
ShapedArray >> eq: anArray [
	(anArray isKindOf: ShapedArray)
		ifFalse: [ ^ self eq: (ShapedArray from: anArray) ].
	^ self with: anArray do: [:l :r | (l = r) asBit ]
]

{ #category : #'api - hooks' }
ShapedArray >> fill [
	^ 0
]

{ #category : #'api - iteration' }
ShapedArray >> filter: aBlock [
	^ (self map: [:e | (aBlock value: e) asBit ])
]

{ #category : #accessing }
ShapedArray >> find: aValue [
	((self filter: [ :e | e = aValue ]) do: [:e :i | e = 1 ifTrue: [ ^ i ]]).
	^ -1
]

{ #category : #'api - shape' }
ShapedArray >> flatten [
	^ self flattenTo: self shape elementCount
]

{ #category : #reshaping }
ShapedArray >> flattenTo: count [
	^ Continuation
		currentDo: [ :cc | 
			| stream |
			stream := LimitedWriteStream on: (Array new: count).
			stream limit: count.
			stream limitBlock: [ cc value: stream contents ].
			self addToStream: stream.
			[ true ]
				whileTrue: [ stream contents do: [:x | stream nextPut: x ]] ]
]

{ #category : #'api - permutation' }
ShapedArray >> gradeDown [
	|indexes|
	"returns a permutation of indexes, that would sort the array in from highest to lowest"
	indexes := self |> [:e :i | i ].
	indexes data sort: [:a :b | (self @ a) > (self @ b)].
	^ indexes asShapedArray
]

{ #category : #'api - permutation' }
ShapedArray >> gradeUp [
	|indexes|
	"returns a permutation of indexes, that would sort the array in from lowest to highest"
	indexes := self |> [:e :i | i ].
	indexes data sort: [:a :b | (self @ a) < (self @ b)].
	^ indexes asShapedArray
]

{ #category : #'gt - views' }
ShapedArray >> gtContentsFor: aView [
	"<gtView>"
	^ aView explicit
		title: 'Contents';
		priority: 0;
		stencil: [ (self rank < 2
			ifTrue: [ self asHorizontal ]
			ifFalse: [self asVertical ]) asPannableElement ];
		actionUpdateButton
]

{ #category : #'gt - views' }
ShapedArray >> gtDisplayString [
	self isString
		ifTrue: [ ^ String newFrom: (self data)].
	^ 'Array: ' , self shape gtDisplayString
]

{ #category : #views }
ShapedArray >> gtHackyMondrianFor: aView [
	"<gtView>"
	^ aView forward
		title: 'Mondrian slop';
		priority: -1;
		object: [ | view |
			view := GtMondrian new.
			view root background: (NordColors polarNight: 1).
			view nodes
				shape: [ :e | self asHorizontal ];
				with: {self}.
			view ];
		view: #gtLiveFor:
]

{ #category : #views }
ShapedArray >> gtHackyVerticalMondrianFor: aView [
	"<gtView>"
	^ aView forward
		title: 'Vertical Mondrian slop';
		priority: -2;
		object: [ | view |
			view := GtMondrian new.
			view root background: (NordColors polarNight: 1).
			view nodes
				shape: [ :e | self asVertical ];
				with: {self}.
			view ];
		view: #gtLiveFor:
]

{ #category : #'gt - actions' }
ShapedArray >> gtInspectShapeActionFor: anAction [
	<gtAction>
	^ anAction button
		icon: BrGlamorousIcons threepanes;
		label: 'Inspect Shape';
		priority: 10;
		action: [ :aButton | aButton phlow spawnObject: self shape ]
]

{ #category : #views }
ShapedArray >> gtTableFor: aView [
	<gtView>
	^ aView explicit
		title: 'Table';
		stencil: [ ScrollableCellTableElement from: self ]
]

{ #category : #'api - hooks' }
ShapedArray >> handleFlatData [
	| newData count stream trailing |
	newData := Array new: self tally.
	trailing := self shape sizes allButFirst.
	count := (trailing inject: 1 into: #*).
	stream := (data forceTo: (self shape elementCount) paddingWith: self fill) readStream.
	1
		to: self tally
		do: [ :i |
			| value d |
			d := (stream next: count).
			value := ShapedArray dims: trailing data: d.
			newData at: i put: value ].
	data := newData
]

{ #category : #'api - hooks' }
ShapedArray >> handleNestedData [
	| newData |
	newData := Array new: self tally.
	1
		to: self tally
		do: [ :index | 
			| value oldValue |
			oldValue := data at: index ifAbsent: [ self fill ].
			value := ShapedArray dims: self shape sizes allButFirst data: oldValue.
			newData at: index put: value ].
	data := newData
]

{ #category : #equality }
ShapedArray >> hash [
	^ self cells inject: 0 into: [:acc :e | acc bitXor: e hash ]
]

{ #category : #'api - indexing' }
ShapedArray >> index: anArray [
	"Gets all elements from self, with the provided indices"
	^ (ShapedArray from: anArray) map: [:e | self at: e ]
]

{ #category : #'view - grid' }
ShapedArray >> indexArrow: e vertical: aBool [
	|arrow bodyColor headColor head|
	bodyColor := (NordColors polarNight: 4).
	headColor := (NordColors aurora: 4).
	arrow := BlParabollaArcElement new
		zIndex: 1;
		curvature: 20;
		border: (BlBorder paint: headColor width: 4).
	head := (BlArrowheadTriangle new
		background: bodyColor;
		border: (BlBorder paint: bodyColor width: 2)).
	
	aBool
		ifTrue: [
			arrow toAnchor: (BlElementTopLeftAnchor element: e children first).
			arrow fromAnchor: (BlElementBottomLeftAnchor element: e children last).
			arrow fromHead: head.
		]
		ifFalse: [
			arrow fromAnchor: (BlElementTopLeftAnchor element: e children first).
			arrow toAnchor: (BlElementTopRightAnchor element: e children last).
			arrow toHead: head.
		].
	
	arrow constraintsDo: [:c | c ignoreByLayout ].
	e addChild: arrow.
	e clipChildren: false.
]

{ #category : #accessing }
ShapedArray >> indexes [
	|indexes|
	indexes := OrderedCollection new.
	self do: [:e :i |
		e = 0
			ifFalse: [ indexes add: i ].
	].
	^ indexes asShapedArray
]

{ #category : #'api - testing' }
ShapedArray >> isAtomic [
	^ false
]

{ #category : #'api - hooks' }
ShapedArray >> isDataFlat [
	^ self data detect: [:each | each isCollection ]
		ifFound: [ false ]
		ifNone: [ true ]
]

{ #category : #'api - testing' }
ShapedArray >> isEmpty [
	^ self data isEmpty
]

{ #category : #'api - testing' }
ShapedArray >> isShaped [
	^ true
]

{ #category : #'api - testing' }
ShapedArray >> isSingleton [
	^ self shape sizes first = 1
]

{ #category : #'api - testing' }
ShapedArray >> isString [
	^ self rank = 1
		and: [ self data allSatisfy: [:e | e isCharacter ]]
]

{ #category : #'api - iteration' }
ShapedArray >> map: aBlock [
	^ self rank: (self rank - 1) map: aBlock
]

{ #category : #'api - shape' }
ShapedArray >> normalize: anArray [
	|common|
	anArray isShaped
		ifFalse: [ ^ self normalize: anArray asShapedArray ].
	common := self commonFrame: anArray.
	^ {self project: common. anArray project: common}
]

{ #category : #'api - element operations' }
ShapedArray >> not [
	^ self |> [:e | e |= 0 ]
]

{ #category : #'view - grid' }
ShapedArray >> onClick: e spawn: anObject [
	e when: BlClickEvent do: [:event | event consumed: true. e phlow spawnOrShowObject: anObject ].
]

{ #category : #'api - hooks' }
ShapedArray >> onDataSet [
	self shape size = 1 ifTrue: [
		data := (self data collect: [:e |
			e isCollection
				ifTrue: [ ShapedArray dims: {e size} data: e ]
				ifFalse: [ e ]
		] as: Array).
		^ self
	]. "If one dimension left, no need to continue shaping"
	self isDataFlat
		ifTrue: [ self handleFlatData]
		ifFalse: [ self handleNestedData]
]

{ #category : #accessing }
ShapedArray >> project: newDims [
	|newData dims|
	dims := newDims asArray.
	self rank = 0
		ifTrue: [ ^ (ShapedArray from: 0) project: newDims ].
	self dims = dims
		ifTrue: [ ^ self ].
	newData := self projectData: dims.
	^ ShapedArray dims: dims data: newData.
]

{ #category : #reshaping }
ShapedArray >> projectData: dims [
	|newData myDims dim rest|
	self dims = dims
		ifTrue: [ ^ self data ]. "If the dims are the same, no need to project"
	
	myDims := self dims forceTo: dims size paddingWith: 1.
	dim := dims first.
	rest := dims allButFirst asArray.
	newData := Array new: dim.
	
	1 to: dim do: [:count |
		|entry|
		entry := self dims size < dims size "If our dims are too small, we recurse"
			ifTrue: [ self projectData: rest ]
			ifFalse: [ self at: count ].
		newData at: count put: entry.
	].
	^ newData
]

{ #category : #'api - shape' }
ShapedArray >> rank [
	^ self shape rank
]

{ #category : #'api - cells' }
ShapedArray >> rank: aRank map: aBlock [
	"applies a block, passing cells of the specified rank as the argument"

	| res |
	self rank <= aRank ifTrue: [ self error: 'Invalid rank!' ].

	res := self rank = (aRank + 1)
			ifTrue: [ self cells
					collectWithIndex: [ :e :i | 
						aBlock
							valueWithPossibleArguments: {e.
									i} ] ]
			ifFalse: [ self cells collect: [ :e | e rank: aRank map: aBlock ] ].
	^ ShapedArray from: res
]

{ #category : #errors }
ShapedArray >> rankError: anArray [
	^ RankError left: self right: anArray
]

{ #category : #'api - iteration' }
ShapedArray >> reduce: anInitialValue using: aBlock [
	^ (self cells
		withIndexCollect: [ :e :i | 
			{e.i} ])
		inject: anInitialValue
		into: [ :acc :e | 
			aBlock
				cull: acc
				cull: e first
				cull: e second ]
]

{ #category : #'api - search' }
ShapedArray >> repeat: anArray [
	"Repeat the major cells of self, for each index in anArray"
	"ie: #(1 2 3) repeat: #(2 2 2) = #(1 1 2 2 3 3)"
	"or: #(1 2 3) repeat: #(1 0 1) = #(1 3)"
	|res|
	res := OrderedCollection new.
	self with: (anArray asShapedArray) do: [:l :r |
		r timesRepeat: [ res add: l ].
	].
	^ ShapedArray from: res
]

{ #category : #'api - shape' }
ShapedArray >> reshape: dims [
	|count|
	dims isCollection
		ifFalse: [ ^ self reshape: {dims} ].
	count := dims inject: 1 into: #*.
	count = 0
		ifTrue: [ ^ ShapedArray unit ].
	^ ShapedArray dims: dims data: (self flattenTo: count).
]

{ #category : #'api - shape' }
ShapedArray >> rows [
	self dims size = 1
		ifTrue: [ ^ 1 ].
	^ self dims first
]

{ #category : #'view - grid' }
ShapedArray >> scalarElement: value depth: depth [
	| el label |
	el := BrHorizontalGrid new
			columnCount: 1;
			border: (BlBorder paint: (NordColors aurora: 1) width: 1);
			padding: (BlInsets all: 10);
			background: ((NordColors frost: 3) alpha: (0.1 * depth));
			fitContent.
	self onClick: el spawn: value.
	label := BrLabel new
		aptitude: (BrLabelAptitude new bold);
		text: value gtDisplayString.
	el addChild: label.
	^ el
]

{ #category : #'api - iteration' }
ShapedArray >> scan: aBlock [
	|prefix|
	^ self map: [:element :index |
		prefix := self reshape: index.
		prefix reduce: 0 using: aBlock
	]
]

{ #category : #'api - shape' }
ShapedArray >> shape [
	^ shape
]

{ #category : #accessing }
ShapedArray >> shape: anObject [
	shape := anObject.
]

{ #category : #'api - testing' }
ShapedArray >> shapeCompatible: anArray [
	[ self commonFrame: anArray ]
		onErrorDo: [^ false].
	^ true
]

{ #category : #accessing }
ShapedArray >> size [
	^ self shape elementCount
]

{ #category : #'api - shape' }
ShapedArray >> tableEntries [
	self rank = 1 ifTrue: [ ^ self cells ].
	^ (self cellsRank: self rank - 2) data
]

{ #category : #accessing }
ShapedArray >> take: num [
	^ self index: (1 to: num).
]

{ #category : #'api - hooks' }
ShapedArray >> tally [
	^ self shape tally
]

{ #category : #accessing }
ShapedArray >> unique [
	|set|
	set := Set new.
	self do: [:e :i | set add: e ]. "this is dumb, should fix"
	^ set asOrderedCollection asShapedArray
]

{ #category : #'private - shape' }
ShapedArray >> validateCommonFrame: anArray [
	|max|
	max := {self rank. anArray asShapedArray rank} max.
	^ self validateCommonFrame: anArray asShapedArray max: max
]

{ #category : #'private - shape' }
ShapedArray >> validateCommonFrame: anArray max: aRank [
	| left right |
	left := (self shape padTo: aRank) sizes.
	right := (anArray shape padTo: aRank) sizes.
	left
		with: right
		do: [ :l :r |
			({[ l = 1 ].
				[ r = 1 ].
				[ l = r ]} noneSatisfy: #value)
					ifTrue: [
					^ RankError left: l right: r.
					] ].
	^ true
]

{ #category : #'api - search' }
ShapedArray >> where: aValue [
	^ ((self filter: [:e | e = aValue])
		reduce: {}
		using: [ :acc :e :i | e = 0 ifTrue: [ acc ] ifFalse: [ acc , i ] ]) asShapedArray
]

{ #category : #'private - cells' }
ShapedArray >> with: anArray dataDo: aBinaryBlock [
	| common result |
	common := anArray commonFrame: self.
	result := OrderedCollection new.
	(self project: common) data
		with: (anArray project: common) data
		do: [ :l :r |
			| val |
			val := l isShaped
					ifTrue: [ l with: r dataDo: aBinaryBlock ]
					ifFalse: [ aBinaryBlock valueWithArguments: {l.r} ].
			result add: val.
			].
	^ result
]

{ #category : #'api - iteration' }
ShapedArray >> with: anArray do: aBinaryBlock [
	| commonFrame newData |
	commonFrame := anArray commonFrame: self.
	newData := self with: anArray dataDo: aBinaryBlock.
	^ ShapedArray dims: commonFrame data: newData
]

{ #category : #'api - alias' }
ShapedArray >> |= arr [
	"alias for eq:"
	^ self eq: arr
]

{ #category : #'api - alias' }
ShapedArray >> |> aBlock [
	"alias for map:"
	"The bar looks vertical, and map doesn't reduce rank by default"
	^ self map: aBlock
]

{ #category : #accessing }
ShapedArray >> |@ anObject [
	"alias for index:"
	^ self index: anObject
]
