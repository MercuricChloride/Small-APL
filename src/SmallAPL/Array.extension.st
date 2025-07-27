Extension { #name : #Array }

{ #category : #'*SmallAPL' }
Array >> copyToSize: targetSize [
	|arr|
	arr := Array new: targetSize.
	1 to: targetSize
		do: [:i |
			|value|
			value := self at: (i - 1) \\ self size + 1.
			arr at: i put: value.
			].
	^ arr
]
