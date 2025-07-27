Class {
	#name : #ArrDim,
	#superclass : #Object,
	#instVars : [
		'stride',
		'size'
	],
	#category : #'SmallAPL-Shapes - Dimensions'
}

{ #category : #'as yet unclassified' }
ArrDim class >> size: aNumber [
	"For building the first dimension of an array"
	^ self new
		size: aNumber;
		stride: 1
]

{ #category : #'as yet unclassified' }
ArrDim class >> size: aNumber prevSize: prevSize stride: aStride [
	"For building the non-first dimensions of an array"
	^ self new
		size: aNumber;
		stride: (prevSize * aStride)
]

{ #category : #'as yet unclassified' }
ArrDim >> gtDisplayString [
	^ 'Dim(' , size asString , ')'
]

{ #category : #'as yet unclassified' }
ArrDim >> size [
	^ size ifNil: [ 1 ]
]

{ #category : #'as yet unclassified' }
ArrDim >> size: aNumber [
	size := aNumber
]

{ #category : #accessing }
ArrDim >> start [
	^ 1
]

{ #category : #accessing }
ArrDim >> stop [
	^ self size
]

{ #category : #accessing }
ArrDim >> stride [
	^ stride
]

{ #category : #accessing }
ArrDim >> stride: anObject [
	stride := anObject
]

{ #category : #'as yet unclassified' }
ArrDim >> validateIndex: index [
	^ index between: self start and: self stop
]
