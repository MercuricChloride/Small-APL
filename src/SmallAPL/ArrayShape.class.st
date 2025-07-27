Class {
	#name : #ArrayShape,
	#superclass : #Object,
	#traits : 'TGtGroupWithItems',
	#classTraits : 'TGtGroupWithItems classTrait',
	#category : #'SmallAPL-Dumb - Arrays'
}

{ #category : #helpers }
ArrayShape class >> buildDimensions: dimensions [
	^ (dimensions reverse
		inject: OrderedCollection new
		into: [ :acc :e | 
			| dimension |
			dimension := acc isEmpty
					ifTrue: [ ArrDim size: e ]
					ifFalse: [ | prev |
						prev := acc last.
						ArrDim
							size: e
							prevSize: prev size
							stride: prev stride ].
			acc , {dimension} ]) reverse
]

{ #category : #creation }
ArrayShape class >> dims: dimensions [
	dimensions isCollection
		ifFalse: [ ^ self dims: {dimensions}].
	
	^ self new
		addAll: (self buildDimensions: dimensions);
		yourself
]

{ #category : #'api - indexing' }
ArrayShape >> elementCount [
	^ self first in: [:dim |
		dim size * dim stride
	].
]

{ #category : #views }
ArrayShape >> gtDimsFor: aView [
	<gtView>
	^ aView forward
		title: 'Dimensions';
		object: [ self items ];
		view: #gtItemsFor:
]

{ #category : #'as yet unclassified' }
ArrayShape >> gtDisplayString [
	| dims |
	dims := self items allButFirst
			inject: self items first size asString , ' '
			into: [ :acc :e | acc , 'x ' , e size asString ].
	^ 'Dims: ' , dims
]

{ #category : #'api - dims' }
ArrayShape >> isUnit [
	^ (self rank = #(1)) or: [ self rank = #(0) ]
]

{ #category : #'api - rank' }
ArrayShape >> padTo: aSize [
	|sizes|
	self items size >= aSize
		ifTrue: [ ^ self ].
	sizes := self sizes.
	^ ArrayShape dims: (sizes forceTo: aSize paddingStartWith: 1)
]

{ #category : #'api - dims' }
ArrayShape >> rank [
	^ self size
]

{ #category : #'view - grid' }
ArrayShape >> scalarElement: value depth: depth [
	| el label |
	el := BrHorizontalGrid new
			columnCount: 1;
			border: (BlBorder paint: (NordColors aurora: 3) width: 2);
			padding: (BlInsets all: 10);
			background: ((NordColors frost: 3) alpha: (0.1 * depth));
			fitContent.
	self onClick: el spawn: value.
	label := BrLabel new
		aptitude: (BrLabelAptitude new bold);
		text: value asString.
	el addChild: label.
	^ el
]

{ #category : #'as yet unclassified' }
ArrayShape >> scan: aBlock along: dim [
    "Accumulates aBlock results along the dimension dim, doesn't effect the rank of the array"
    | sliceCount accumulator results |
    sliceCount := (self items at: dim) size.
    accumulator := nil.
    results := OrderedCollection new.
    
    1 to: sliceCount do: [:i |
        | slice |
        slice := self sliceAt: i along: dim.
        accumulator := accumulator
            ifNil: [slice]
            ifNotNil: [aBlock value: accumulator value: slice].
        results add: accumulator ].
        
    ^ results
]

{ #category : #'api - dims' }
ArrayShape >> sizes [
	^ self items collect: #size as: Array
]

{ #category : #'as yet unclassified' }
ArrayShape >> sliceAt: index along: dimension [
    "Extract slice at specific index in given dimension"
    ^ (self get: dimension)
]

{ #category : #'api - offset' }
ArrayShape >> strides [
	^ self items collect: #stride
]

{ #category : #'as yet unclassified' }
ArrayShape >> tally [
	"Returns the count of major cells in the array"
	self size = 0
		ifTrue: [ ^ 0 ].
	^ self first size
]

{ #category : #'api - dims' }
ArrayShape >> trailingDims: indexes [
	^ self items allButFirst: indexes size
]

{ #category : #'api - validation' }
ArrayShape >> validateIndexes: indexes [
	indexes isCollection not
		ifTrue: [ ^ self validateIndexes: {indexes} ].
	
	(self items first: (indexes size)) with: indexes do: [:dim :i |
		(dim validateIndex: i)
			ifFalse: [ self error: 'Invalid index access!']
	].
	^ true
]
