Class {
	#name : #RankError,
	#superclass : #Error,
	#category : #'SmallAPL-Error'
}

{ #category : #'as yet unclassified' }
RankError class >> left: left right: right [
	|msg|
	msg := 'Incompatible dimensions: {1} and: {2}' format: {left. right}.
	^ self signal: msg
]
