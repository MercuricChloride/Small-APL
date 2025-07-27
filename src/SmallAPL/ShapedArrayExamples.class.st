Class {
	#name : #ShapedArrayExamples,
	#superclass : #Object,
	#category : #'SmallAPL-Examples - Arrays'
}

{ #category : #'as yet unclassified' }
ShapedArrayExamples >> basic [
	<gtExample>
	|arr|
	arr := #(1 2 3) asShapedArray.
	
	self assert: arr shape = #(3).
	self assert: arr shape = #(3).
	^ arr
]

{ #category : #'as yet unclassified' }
ShapedArrayExamples >> indexingColumns [
	<gtExample>
	| alice bob users names ages isUnc isYung |
	alice := 1.
	bob := 2.	"we can use numbers to represent semantic things. IE a user in our system"
	users := (1 to: 2) asShapedArray.
	self assert: (users index: alice) = 1.
	self assert: (users index: bob) = 2.	"if arrays have the same shape, we can do semantic indexing"
	names := {#alice.
			#bob} asShapedArray. "here every index corresponds to a name of a user"

	ages := {24.
			69} asShapedArray.
	self assert: (ages index: alice) = 24.
	self assert: (ages index: bob) = 69.	"The index doesn't define the properties, so we are free to build other types of indexes as well. IE an age check"

	isUnc := ages filter: [ :e | e > 42 ].	"isUnc is a mask, meaning its a boolean array representing true or false values. Therefore we can index into it to check properties!"
	self assert: (isUnc index: bob) = 1.
	self assert: (isUnc index: alice) = 0.	"Because isUnc is also an array, we can also invert it!"
	isYung := isUnc xor: 1.
	self assert: (isYung index: bob) = 0.
	self assert: (isYung index: alice) = 1.
	^ isYung
]

{ #category : #'as yet unclassified' }
ShapedArrayExamples >> indexingWithArrays [
	<gtExample>
	|arr indexArr|
	arr := self reshaped.
	indexArr := #(1 2 3) asShapedArray.
	"we can index full paths"
	self assert: (arr index: indexArr) = 2.
	indexArr := #(1 2) asShapedArray.
	"we can access particular dimensions of the array"
	self assert: (arr index: indexArr) size = 5.
	"To just access a particular dimension of the first axis, we can index with a number"
	self assert: (arr index: 3) size = 5.
	^ arr
]

{ #category : #'as yet unclassified' }
ShapedArrayExamples >> ravel [
	<gtExample>
	|arr|
	"All arrays have 2 parts, the shape and the ravel"
	"The ravell is the flat version of the array, and the shape is how we view the ravel"
	arr := self reshaped.
	self assert: (arr shape = #(5 5 5)).
	self assert: (arr ravel size = 125).
]

{ #category : #'as yet unclassified' }
ShapedArrayExamples >> reshaped [
	<gtExample>
	|arr|
	"we can reshape arrays, the default behavior of reshaping is to effectively repeat the contents"
	arr := self basic reshape: #(5 5 5).
	^ arr
]

{ #category : #'as yet unclassified' }
ShapedArrayExamples >> tables [
	<gtExample>
	| alice bob users notes uncMask uncs |
	"each row is of form: [name, age]"
	alice := 1.
	bob := 2.

	users := #(alice 24 bob 69) asShapedArray: #(2 2).	"here we are using a table to store data that is naturally related"

	notes := #('weirdo' 'cool dude') asShapedArray.

	notes index: alice.
	notes index: bob.

	uncMask := users across: [ :e | ((e index: 2) > 24) asBit ].	"here we are going across each row, to perform a calculation"
	self assert: uncMask ravel = #(0 1).	"Now each row has been replaced with a boolean value in uncs."
	uncs := users replicateFirst: uncMask.	"copies each dimension passed in the array x times, so a boolean mask here removes rows that aren't unc."
	self assert: uncs ravel = #(bob 69).
	self assert: (users replicateFirst: #(0 3) asShapedArray) ravel = #(bob 69 bob 69 bob 69).
	^ uncs
]
