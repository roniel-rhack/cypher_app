import ArgumentParser
import Foundation
import RNCryptor

struct CypherApp: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Encrypt and decrypt files", version: "0.0.1")
    
    @Argument(help: "Password for encrypting and decrypting")
    var password: String
    
    @Option(name: .shortAndLong, help: "Input file name")
    var inputFile: String
    @Option(name: .shortAndLong, help: "Output file name")
    var outputFile: String
    @Flag(name: .shortAndLong, help: "Decrypt file")
    var decrypt = false
    
    func run() throws {
        var converted = ""
        guard let input = try? String(contentsOfFile: inputFile) else {
            throw RuntimeError("Couldn't read from file '\(inputFile)'")
        }
        
        if decrypt {
            do {
                converted = try decryptContents(encryptedContents: input)
            } catch {
                throw RuntimeError("Couldn't encrypt '\(inputFile)'")
            }
        } else {
            converted = encryptContents(contents: input)
        }
        
        guard let _ = try? converted.write(toFile: outputFile, atomically: true, encoding: .utf8) else {
            throw RuntimeError("Couldn't write to file '\(outputFile)'")
        }
        
    }
    
    func encryptContents(contents: String) -> String {
        let contentsData = contents.data(using: .utf8)!
        let cipherData = RNCryptor.encrypt(data: contentsData, withPassword: password)
        return cipherData.base64EncodedString()
    }
    
    func decryptContents(encryptedContents: String) throws -> String {
        let encryptedData = Data.init(base64Encoded: encryptedContents)!
        let decryptedData = try RNCryptor.decrypt(data: encryptedData, withPassword: password)
        let decryptedString = String(data: decryptedData, encoding: .utf8)!
        return decryptedString
    }
    
}



struct RuntimeError: Error, CustomStringConvertible {
    var description: String
    
    init(_ description: String) {
        self.description = description
    }
}

CypherApp.main()
