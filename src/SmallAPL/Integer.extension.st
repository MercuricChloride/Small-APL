Extension { #name : #Integer }

{ #category : #'*SmallAPL' }
Integer >> iota [
	^ (1 to: self) asShapedArray
]
