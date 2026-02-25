import Foundation

enum TestFixture {
    static func loadJSON(_ filename: String) throws -> Data {
        let bundle = Bundle(for: BundleToken.self)
        guard let url = bundle.url(forResource: filename, withExtension: nil, subdirectory: "fixtures") else {
            throw FixtureError.fileNotFound(filename)
        }
        return try Data(contentsOf: url)
    }

    static func decode<T: Decodable>(_ type: T.Type, from filename: String) throws -> T {
        let data = try loadJSON(filename)
        return try JSONDecoder().decode(type, from: data)
    }

    enum FixtureError: Error {
        case fileNotFound(String)
    }
}

private final class BundleToken {}
