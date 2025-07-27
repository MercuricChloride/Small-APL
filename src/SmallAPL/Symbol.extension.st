Extension { #name : #Symbol }

{ #category : #'*SmallAPL' }
Symbol >> value: anObject value: secondArg [
	^ anObject perform: self withEnoughArguments: { secondArg }
]
