Extension { #name : #SequenceableCollection }

{ #category : #'*SmallAPL' }
SequenceableCollection >> asShapedArray [
	^ ShapedArray from: self
]
