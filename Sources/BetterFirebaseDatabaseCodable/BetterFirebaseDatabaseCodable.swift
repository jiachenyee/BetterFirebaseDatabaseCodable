import FirebaseDatabaseSwift
import Firebase

public extension Firebase.DataSnapshot {
    /// Retrieves the value of a snapshot and converts it to an instance of
    /// caller-specified type.
    ///
    /// Similar to Firebase's original implementation, however, this implementation
    /// will work well with empty arrays and will not require all of them be converted to optionals.
    ///
    /// **Usage**
    ///
    /// You will need to provide a `defaultValue` to use if the value does not exist on the Firebase Database.
    ///
    /// ```swift
    /// ref.getData { data, snapshot in
    ///     do {
    ///         print(try snapshot.data(defaultValue: SampleData(values: [], moreValues: [])))
    ///     } catch {
    ///         print(error.localizedDescription)
    ///     }
    /// }
    /// ```
    ///
    /// **What's wrong with Firebase's implementation?**
    ///
    /// Firebase Database is built to store dictionaries, which means it does not handle arrays well. See [this](https://stackoverflow.com/a/48463446).
    ///
    /// Let's say you're creating a struct with empty arrays
    /// ```swift
    /// struct SampleData: Codable {
    ///     var values: [String]
    ///     var moreValues: [String]
    /// }
    /// ```
    ///
    /// An empty array gets treated as if it doesn't exist by the encoder and this will lead to strange situations like this:
    ///
    /// Writing data with empty arrays to FIrebase using the `Codable` implementation:
    /// ```swift
    /// try ref.setValue(from: SampleData(value: [], moreValue: []))
    /// try ref.setValue(from: SampleData(value: ["potato"], moreValue: []))
    /// try ref.setValue(from: SampleData(value: [], moreValue: ["tomato"]))
    /// ```
    ///
    /// Retrieving data (an error is thrown):
    /// ```swift
    /// ref.getData { data, snapshot in
    ///     do {
    ///         print(try snapshot.data(as: SampleData.self))
    ///     } catch {
    ///         print(error.localizedDescription)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - type: The type to convert the document fields to.
    ///   - defaultValue: A value used to replace any missing values
    ///   - decoder: The decoder to use to convert the document. Defaults to use
    ///   default decoder.
    /// - Returns: Throws `DecodingError.valueNotFound`
    ///            if the document does not exist and `T` is not an `Optional`.
    ///
    ///             See `Database.Decoder` for more details about the decoding process.
    func data<T: Decodable>(defaultValue: T,
                            decoder: Database.Decoder =
                            Database.Decoder()) throws -> T {
        
        if var value = value as? [String: Any] {
            let mirror = Mirror(reflecting: defaultValue)
            
            for child in mirror.children where value[child.label ?? ""] == nil {
                guard let label = child.label else { continue }
                value[label] = child.value
            }
            
            return try decoder.decode(T.self, from: value)
        }
        
        return try decoder.decode(T.self, from: value ?? NSNull())
    }
}
