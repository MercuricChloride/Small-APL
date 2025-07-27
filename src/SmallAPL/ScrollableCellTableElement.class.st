Class {
	#name : #ScrollableCellTableElement,
	#superclass : #BrScrollPane,
	#category : #'SmallAPL-Elements'
}

{ #category : #'as yet unclassified' }
ScrollableCellTableElement class >> from: anArray [
	^ self new
		content: (CellTableElement fromShapedArr: anArray asShapedArray)
]

{ #category : #'as yet unclassified' }
ScrollableCellTableElement >> initialize [
	super initialize.
	self aptitude: BrScrollPaneAptitude  + BrGlamorousWithVerticalScrollbarAptitude.
	self matchParent.
]
