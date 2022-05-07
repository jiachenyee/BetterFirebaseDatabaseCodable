# Better Firebase Database `Codable`

An extension to `Firebase.DataSnapshot` that makes it work well with empty arrays.

## Usage

You will need to provide a `defaultValue` to use if the value does not exist on the Firebase Database.

```swift
ref.getData { data, snapshot in
    do {
        print(try snapshot.data(defaultValue: SampleData(values: [], moreValues: [])))
    } catch {
        print(error.localizedDescription)
    }
}
```

## What's wrong with Firebase's implementation?

Firebase Database is built to store dictionaries, which means it does not handle arrays well. See [this](https://stackoverflow.com/a/48463446).

Let's say you're creating a struct with empty arrays
```swift
struct SampleData: Codable {
    var values: [String]
    var moreValues: [String]
}
```

An empty array gets treated as if it doesn't exist by the encoder and this will lead to strange situations like this:

Writing data with empty arrays to FIrebase using the `Codable` implementation:
```swift
try ref.setValue(from: SampleData(value: [], moreValue: []))
try ref.setValue(from: SampleData(value: ["potato"], moreValue: []))
try ref.setValue(from: SampleData(value: [], moreValue: ["tomato"]))
```

Retrieving data (an error is thrown):
```swift
ref.getData { data, snapshot in
    do {
        print(try snapshot.data(as: SampleData.self))
    } catch {
        print(error.localizedDescription)
    }
}
```

## Why?
I wanted to store arrays in Firebase, and naturally, I thought

> if I use the same encoder, and the same decoder, I will definitely get the same value back. I mean, it would be ridiculous for that not to be the case. 

I spent an hour debugging and [submitting an issue](https://github.com/firebase/firebase-ios-sdk/issues/9742) to learn about Firebase's aversion to arrays.

So here we are. This package provides a way to provide default values that can substitute missing values when decoding data from Firebase Database.
