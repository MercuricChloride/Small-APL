Class {
	#name : #BaselineOfSmallAPL,
	#superclass : #BaselineOf,
	#category : #BaselineOfSmallAPL
}

{ #category : #baseline }
BaselineOfSmallAPL >> baseline: spec [
	<baseline>
		^ spec for: #common do: [
			spec package: 'SmallAPL'
		]
]
