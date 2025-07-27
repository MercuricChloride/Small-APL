Class {
	#name : #CellTableElement,
	#superclass : #BrHorizontalGrid,
	#instVars : [
		'rows',
		'cols',
		'value'
	],
	#category : #'SmallAPL-Elements'
}

{ #category : #'as yet unclassified' }
CellTableElement class >> fromShapedArr: arr [
	^ self new
		rows: arr rows;
		cols: arr cols;
		value: arr
]

{ #category : #'as yet unclassified' }
CellTableElement >> cols: anObject [
	cols := anObject
]

{ #category : #'as yet unclassified' }
CellTableElement >> coordFor: index [
    | row col |
    rows = 1
    	ifTrue: [ ^ {index} ].
    row := ((index - 1) // cols) + 1.
    col := ((index - 1) \\ cols) + 1.
    ^ { row. col }
]

{ #category : #'as yet unclassified' }
CellTableElement >> initialize [
	super initialize.
	self vFitContent;
		hMatchParent;
		cellSpacing: 5;
		layoutDo: [:l |.
			l alignMargins];
		background: Color white
]

{ #category : #'as yet unclassified' }
CellTableElement >> onRemovedFromSceneGraph [
	super onRemovedFromSceneGraph.
	value := nil.
]

{ #category : #'as yet unclassified' }
CellTableElement >> rows: anInteger [
	rows := anInteger
]

{ #category : #'as yet unclassified' }
CellTableElement >> value: anObject [
	|isFlat|
	isFlat := false.
	value := anObject.
	self
		layoutDo: [ :l | 
	
			value rows = 1
				ifTrue: [
					isFlat := true.
					l rowCount: value cols.
					l columnCount: value rows ]
				ifFalse: [ l rowCount: value rows.
					l columnCount: value cols ] ].
	self addChildren: (value tableEntries collectWithIndex: [ :x :i |
		isFlat
			ifTrue: [ CellElement from: value index: (self coordFor: i) last ]
			ifFalse: [ CellElement from: value index: (self coordFor: i) ]
	 ])
]
