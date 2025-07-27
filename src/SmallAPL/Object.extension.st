Extension { #name : #Object }

{ #category : #'*SmallAPL' }
Object >> asShapedArray [
	^ self enclose
]

{ #category : #'*SmallAPL' }
Object >> asShapedArray: aShape [
	^ self asShapedArray
		shape: aShape
]

{ #category : #'*SmallAPL' }
Object >> commonFrame: anArray [
	(anArray isKindOf: ShapedArray)
		ifFalse: [ ^ self commonFrame: anArray enclose ].
	^ self enclose commonFrame: anArray
]

{ #category : #'*SmallAPL' }
Object >> depth [
	^ 0
]

{ #category : #'*SmallAPL' }
Object >> enclose [
	^ ShapedArray unit: self
]

{ #category : #'*SmallAPL' }
Object >> extend: aSize [
	|arr|
	arr := self asMultiArr.
	arr defaultElement: self.
	^ arr extend: aSize
]

{ #category : #'*SmallAPL' }
Object >> isAtomic [
	^ true
]

{ #category : #'*SmallAPL' }
Object >> isScalar [
	^ true
]

{ #category : #'*SmallAPL' }
Object >> isShaped [
	^ false
]

{ #category : #'*SmallAPL' }
Object >> normalize: aMulti [
	^ self asMultiArr normalize: aMulti
]

{ #category : #'*SmallAPL' }
Object >> project: dims [
	^ self enclose reshape: dims
]

{ #category : #'*SmallAPL' }
Object >> projectData: dims [
	dims size = 1
		ifTrue: [
			^ (1 to: dims first) collect: [:x | self ]
		].
	^ (1 to: dims first) collect: [:x |
		self projectData: dims allButFirst
	].
]

{ #category : #'*SmallAPL' }
Object >> rank [
	^ 0
]

{ #category : #'*SmallAPL' }
Object >> reshape: dims [
	^ self enclose reshape: dims
]
