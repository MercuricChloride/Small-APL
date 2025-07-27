Class {
	#name : #DShapedArrayExamples,
	#superclass : #Object,
	#traits : 'TDShapedArrayHelpers',
	#classTraits : 'TDShapedArrayHelpers classTrait',
	#category : #'SmallAPL-Examples - Arrays'
}

{ #category : #'as yet unclassified' }
DShapedArrayExamples >> basic [
	<gtExample>
	|arr|
	arr := ShapedArray iota: #(3).
	
	self assert: arr rank = 1.
	self assert: arr dims = #(3).
	^ arr
]

{ #category : #'as yet unclassified' }
DShapedArrayExamples >> cellRank [
	<gtExample>
	| arr rank0 rank1 |
	arr := self iota: #(3 3).
	rank0 := arr cellsRank: 0.
	self assert: rank0 = (1 to: 9) asOrderedCollection.
	self assert: (arr <> 0) = rank0. "<> is an alias for cellsRank:"
	rank1 := arr cellsRank: 1.
	self assert: rank1 = #(#(1 2 3) #(4 5 6) #(7 8 9)) asOrderedCollection.
	^ rank0
]

{ #category : #'as yet unclassified' }
DShapedArrayExamples >> commonFrame [
	<gtExample>
	|left right common|
	left := self iota: #(5 5).
	right := self iota: 5.
	common := left commonFrame: right.
	self assert: common = #(5 5).
	^ common
]

{ #category : #'as yet unclassified' }
DShapedArrayExamples >> concat [
	<gtExample>
	| left right concat |
	left := self iota: 5.
	right := 6.
	concat := left concat: right.
	self assert: concat = #(1 2 3 4 5 6).
	
	left := self iota: 3.
	right := self iota: 3.
	concat := left , right.
	self assert: concat = #(1 2 3 1 2 3).
	
	left := self iota: #(3 3).
	right := self iota: #(3 3).
	^ left , right
]

{ #category : #'as yet unclassified' }
DShapedArrayExamples >> equality [
	<gtExample>
	|a b|
	a := self basic.
	b := #(1 2 3).
	self assert: a = b.
]

{ #category : #'as yet unclassified' }
DShapedArrayExamples >> indexingColumns [
	"<gtExample>"
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
DShapedArrayExamples >> indexingWithArrays [
	"<gtExample>"
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
DShapedArrayExamples >> iotaSimple [
	<gtExample>
	|arr|
	arr := ShapedArray iota: #(3). "Iota builds an array filled with the values 1-X, from a shape description"
	self assert: arr flatten = #(1 2 3).
	arr := ShapedArray iota: #(3 3). "Iota can also build multi-dimensional arrays"
	self assert: (arr rank = 2). "Arr has 2 dimensions"
	self assert: arr dims = #(3 3). "It's sizes are [3,3]"
	self assert: (arr at: 1) = #(1 2 3). "arr[1] = [1,2,3]"
	self assert: (arr at: 2) = #(4 5 6). "arr[2] = [4,5,6]"
	self assert: arr flatten = #(1 2 3 4 5 6 7 8 9).
	^ arr
]

{ #category : #'as yet unclassified' }
DShapedArrayExamples >> mapping [
	<gtExample>
	|arr result|
	arr := self basic.
	result := (arr map: [:e | e * 10]).
	self assert: result = #(10 20 30).
	self assert: (result = (arr |> [:e | e * 10 ])).
	^ result
]

{ #category : #'as yet unclassified' }
DShapedArrayExamples >> masking [
	<gtExample>
	| arr result oddMask |
	arr := self iota: 5.
	oddMask := arr ?> #odd.
	result := arr repeat: oddMask.
	self assert: result = #(1 3 5).
	^ result
]

{ #category : #'as yet unclassified' }
DShapedArrayExamples >> project [
	<gtExample>
	| a b c result|
	a := self iota: 5.
	b := 1.
	c := a + b.
	self assert: c = #(2 3 4 5 6).
	
	a := self iota: 3.
	b := self iota: #(3 3).
	c := a eq: b.
	result := self from: #((1 1 1) (0 0 0) (0 0 0)).
	self assert: c = result.
	^ result
]

{ #category : #'as yet unclassified' }
DShapedArrayExamples >> projectionEquality [
	<gtExample>
	| arr result |
	arr := self iota: 5.
	result := arr |= 5.
	self assert: result = #(0 0 0 0 1).
	^ result
]

{ #category : #'as yet unclassified' }
DShapedArrayExamples >> ravel [
	<gtExample>
	|arr|
	"All arrays have 2 parts, the shape and the ravel"
	"The ravel is the flat version of the array, and the shape is how we view the ravel"
	arr := self reshaped.
	self assert: (arr rank = 3).
	self assert: (arr dims = #(5 5 5)).
	self assert: (arr size = 125).
]

{ #category : #'as yet unclassified' }
DShapedArrayExamples >> relativeIndexing [
	<gtExample>
	|users notes alice bob|
	alice := 1.
	bob := 2.
	users := self tables.
	
	notes := self from: #('weirdo' 'cool').
	self assert: (notes at: alice) = 'weirdo'.
	self assert: (notes at: bob) = 'cool'.
	^ users @ alice
	"^ self from: {users. notes}"
]

{ #category : #'as yet unclassified' }
DShapedArrayExamples >> repeating [
	<gtExample>
	|arr result|
	arr := self iota: 3.
	result := arr repeat: #(1 0 1).
	self assert: result = #(1 3).
	result := arr repeat: 2.
	self assert: result = #(1 1 2 2 3 3).
	^ result
]

{ #category : #'as yet unclassified' }
DShapedArrayExamples >> reshaped [
	<gtExample>
	|arr reshaped|
	"we can reshape arrays, the default behavior of reshaping is to repeat the flattened contents of the array"
	arr := self basic.
	#(1 2 3)
		do: [:x | (arr at: x) ].
	reshaped := arr reshape: #(5 5 5).
	^ reshaped
]

{ #category : #'as yet unclassified' }
DShapedArrayExamples >> scan [
	<gtExample>
	|arr scanned|
	arr := self iota: 5.
	scanned := arr scan: [:acc :e | acc + e ].
	self assert: (scanned = #(1 3 6 10 15)).
	^ scanned
]

{ #category : #'as yet unclassified' }
DShapedArrayExamples >> simpleFilter [
	<gtExample>
	|arr result|
	arr := self basic.
	result := arr ?> #odd.
	^ result
]

{ #category : #'as yet unclassified' }
DShapedArrayExamples >> tables [
	<gtExample>
	|users|
	"each row is of form: [name, age]"
	users := self dims: #(2 2) data: #((alice 24) (bob 69)).	"here we are using a table to store data that is naturally related"
	^ users.

	"uncMask := users across: [ :e | ((e index: 2) > 24) asBit ]."	"here we are going across each row, to perform a calculation"
	"self assert: uncMask ravel = #(0 1)."	"Now each row has been replaced with a boolean value in uncs."
	"uncs := users replicateFirst: uncMask."	"copies each dimension passed in the array x times, so a boolean mask here removes rows that aren't unc."
	"self assert: uncs ravel = #(bob 69)."
	"self assert: (users replicateFirst: #(0 3) asShapedArray) ravel = #(bob 69 bob 69 bob 69)."
]
