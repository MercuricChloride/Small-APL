Class {
	#name : #CellElement,
	#superclass : #BrVerticalPane,
	#instVars : [
		'parentArr',
		'index'
	],
	#category : #'SmallAPL-Elements'
}

{ #category : #'as yet unclassified' }
CellElement class >> from: aValue index: anIndex [
	^ self new
		parentArr: aValue;
		index: anIndex
]

{ #category : #'as yet unclassified' }
CellElement >> index: aCoordinate [
	index := aCoordinate.
]

{ #category : #'as yet unclassified' }
CellElement >> initialize [
	super initialize.
	self aptitude: BrVerticalPaneAptitude.
]

{ #category : #'as yet unclassified' }
CellElement >> inspectValue [
	self phlow spawnObject: self value
]

{ #category : #'as yet unclassified' }
CellElement >> label: aString [
	(self childWithId: #label) text: aString asRopedText
]

{ #category : #'as yet unclassified' }
CellElement >> onAddedToSceneGraph [
	super onAddedToSceneGraph.
	self padding: (BlInsets all: 3).
	self border: (BlBorder paint: Color black width: 2).

	self addEventHandlerOn: BlDoubleClickEvent do: [ :event | self inspectValue ].

	self hMatchParent.

	self alignCenter.
	self
		addChild: (BrLabel new
				aptitude: (BrLabelAptitude new
						light;
						glamorousCodeTinySize);
				text: index;
				constraintsDo: [ :c | c ignoreByLayout ]).
	self
		childWithId: #fooLabel
		ifFound: [  ]
		ifNone: [
			self
				addChild: (BrLabel new
					aptitude: BrGlamorousLabelAptitude;
					text: (self value gtDisplayString)
					)
				as: #fooLabel.

			"self label: self value gtDisplayString "]
]

{ #category : #'as yet unclassified' }
CellElement >> onRemovedFromSceneGraph [
	super onRemovedFromSceneGraph.
]

{ #category : #accessing }
CellElement >> parentArr [
	^ parentArr ifNotNil: [:v | v at: 1]
]

{ #category : #accessing }
CellElement >> parentArr: anObject [
	parentArr := anObject asWeakReference
]

{ #category : #'as yet unclassified' }
CellElement >> value [
	^ self parentArr @ index
]
