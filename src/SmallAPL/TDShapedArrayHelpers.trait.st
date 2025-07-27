Trait {
	#name : #TDShapedArrayHelpers,
	#category : #'SmallAPL-Examples - Arrays'
}

{ #category : #helpers }
TDShapedArrayHelpers >> dims: dims data: data [
	^ ShapedArray dims: dims data: data
]

{ #category : #'as yet unclassified' }
TDShapedArrayHelpers >> from: anArray [
	^ ShapedArray from: anArray
]

{ #category : #'as yet unclassified' }
TDShapedArrayHelpers >> iota: dims [
	^ ShapedArray iota: dims
]

{ #category : #'as yet unclassified' }
TDShapedArrayHelpers >> shaping: anArray [
	^ ShapedArray dims: {(anArray size)} data: anArray
]
