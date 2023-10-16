//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by ΙωάνναΑναστασάκη on 12/8/23.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    //catch connectivity error
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
                
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) } //{ error in capturedError = error } same way to write it like  { capturedError = $0 }
        
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    //MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    //move HTTPClientSpy to the test scope class as it is not belong to the production code, it is just a helpul
    //class for testing
    private class HTTPClientSpy: HTTPClient {
        
        private var messages = [(url: URL, completion: (Error) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }

        func get(from url: URL, completion: @escaping(Error) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(error)
        }
    }
    
}



/***
 ===============From Singletons and Globals to Proper Dependency Injection LECTURE ===============
 
 Some theory for this lecture
 
 sut: system under test-small piece of code to test
 The tests in this file are specifically for RemoteFeedLoader, so the sut is RemoteFeedLoader
 
 Collaborator: Like Alamofire, URLSession, HttpClient
 
 XCTAssert: asserts that an expression is true
 
 test_init_doesNotRequestDataFromURL():
 first test - We did not make url request since that should only happen when .load() is invoked
 
 test_load_requestDataFromURL():
 second test -  in this test is expected to call load() from RemoteFeedLoader and get the data from the internet.
 We can pass client to RemoteFeedLoader fwith dependency injection(
    Constructor Dependency ijection:   let sut = RemoteFeedLoader(client: client)
    Property dependency injection: sut.client = client
    method dependency injection: sut.load(client: client)
    )
 
But instructors suggest not dependency injection but a more concrete way to communicate RemoteFeedLoader and HttpClient, Singleton Impementation.
 
 The test are passed, but why to have Singleton HttpClient and not have as many HttpClients as i want?
 The goal is to refactor and get rid of the Singleton:
 How?
 1.make shared a var(it will be not singleton anymore).
 2.Move test logic from the RemoteFeedUrl to HttpClient(the false url line)
 3. Move the test logic ta a new subclass of the HttpClient(making shared property var
 instead of let, open the possibility to make subclass of HttpClient. We do not want the requestedUrl
 to HttpClient class as it exists only for testing purposes)
 4. Swap HttpClient shared instance with the spy subclass during tests
 5. Remove HttpClient private initializer(constructor) since its not a Singleton anymore
 //We do not have a Singleton anymore and the test logic is now in the test type - spy class
 
 10:22
 Not good approach to use share instance directly at
 HTTPClient.shared.get(from: URL(string: "http://a-url.com")!)
because we are mixing responsibilities - responsibility of invoking a method in an object
 and responsibility of locating this object. I f we inject our client we have more control in our code, we do not want to know ehich Http instance i am using.
 Using constructor dependency injection to RemoteFeedUrl, i did not need shaed instance and when i deleted
 sharedInstance from HttpClient class, it was looking like an abstract class, as it had only the get method that the spy class already ovverided. So we make HttpClient to protocol and the spy class just conforms to it.
 
 
 Recap:
 We don't need to start by conforming to the <FeedLoader> protocol. We can take smaller and safer
 steps by test-driving implementation
 
 HTTPClient has no reason to ba a Singleton or shared instance, apart from the convenience to locate the instance
 directly
 
 The RemoteFeedLoader does not need to locate or instantiate the HTTPClient instance. Instead, we can make our code more modular by injecting the HTTPClient as a dependency(by injecting dependencies - low coupling between
 modules)
 
 HTTPClient does not need to be a class. It is just a contract defining which external functionality the RemoteFeedLoader needs, so a protocol is a more suitable way to define it
 HTTPClient is just a contract which defines which external functionality RemoteFeedLoader needs and
 a protocol is more convinient to define a contract.
 By creating a clean separation with protocols, we made the RemoteFeedLoader more flexible, open fot
 extension(Alamofire,URLSession) fo and more testable and not depend to concrete types(URLSession)
 
 Refactor Singleton with dependency injection.
 
 
 
 ===============Asserting a Captured Value Is Not Enough + Cross-Module Access Control===============
 
 Move RemoteFeedLoader class and HTTP protocol from this test file to production code.
 But then how the testcode will have access to the class and protocol, Two ways:
 Import the EssentialFeed library and we have to decide if:
 
 1.
 Use @testable, which makes the internal types visible to the test target(@testable import EssentialFeed)
 -Benefit: we 're free to change internal and private implementation details without breaking tests.
 
 2. Import  EssentialFeed library  without annotation and make HTTPprotocol, RemoteFeedLoader class and its constructor+func public(properties can be private). We can make RemoteFeedLoader Final in order to not be
 subclassed(we chose that approach)
 
 When testing objects collaborating, asserting the values passed is not enough. We also need to ask "how many times was the method invoked?"( XCTAssertEqual(client.requestedURL, url)). If for example
 the load method has double times the client.get(from: url)  in RemoteFeedVC...it is unexpected behaviour and the test will pass. It is important because i do not want to have multiple api calls.
 
 
 order/equality and count for two arrays to be equal
 
 
 
 ===============Handling Errors + Stubbing vs. Spying + Eliminating Invalid Paths===============
 
 We have to check for errors from client side, when we try to get the data(test_load_deliversErrorOnClientError()))
 public func load(completion: (Error) -> Void = { _ in}) {
     client.get(from: url)
 }// void has the ={_ in}, a default closure in order not to brake the other tests
 and this way can have two implementations at once:
 func test_load_requestsDataFromURL() {    sut.load() }
 func test_load_deliversErrorOnClientError() { sut.load { capturedError.append($0) }
 
 - First attemp:
 
 func test_load_deliversErrorOnClientError() {
     let (sut, client) = makeSUT()
     
     var capturedErrors = RemoteFeedLoader.Error?
     sut.load { error in capturedError = error }
     
     XCTAssertEqual(capturedErrors, .connectivity)
 }
 Here i have check that when i try to make a call(load) from RemoteFeddLoader,
 i get a connectivity error.
 But now i want to go further this implementation and notify client(HTTPSpy) that
 it fails with error. And now we stub the client in order to achieve it(stub = set a default error to HTTPSpy). So i add to HTTPSpy the var error but i want the HTTPClient to send an error to RemoteFeedLoader. We will use a closure for that at HTTPClient get function.
 If i understand correctly, the RemoteFeedLoader class has a connectivity error in completion, as it wants to notify the app that if there is a failing in HTTPClient(400,500 whatever), the error that i have to send to the rest of the app is connectivity error
 //RemoteFeedLoader
 public func load(completion: @escaping(Error) -> Void = { _ in}) {
     client.get(from: url) { error in
         completion(.connectivity)
     }
 }
 
 public protocol HTTPClient {
     func get(from url: URL, completion: @escaping(Error) -> Void)
 }
 
 func test_load_deliversErrorOnClientError() {
     let (sut, client) = makeSUT()
     client.error = NSError(domain: "Test", code: 0) //stub client, we set a default error

     var capturedErrors = RemoteFeedLoader.Error?
     sut.load { error in capturedError = error }
     
     XCTAssertEqual(capturedErrors, [.connectivity])
 }
 
 //coding cleanup
 
 func test_load_deliversErrorOnClientError() {
     let (sut, client) = makeSUT()
             
     var capturedErrors = [RemoteFeedLoader.Error]()//many errors - cleanup
     sut.load { capturedErrors.append($0) } //{ error in capturedError = error } same way to write it like  { capturedError = $0 } //cleanup
     
     let clientError = NSError(domain: "Test", code: 0)
     client.complete(with: clientError)
     
     XCTAssertEqual(capturedErrors, [.connectivity])
 }

 //Please see essential developers comments for this
 Arrange:
 let (sut, client) = makeSUT()
 client.error = NSError(domain: "Test", code: 0) //stub client, we set a default error
 
 Given the sut and its HTTPcleint that will always fail with a given error(stubbed behaviour)!!!!!
 
 Act: When we tell the sut to load(invoke the behaviour that we want to test)
 var capturedErrors = [RemoteFeedLoader.Error]()
 sut.load { capturedErrors.append($0)
 
 Assert: We expect the captured load error to be the connectivity error
 XCTAssertEqual(capturedErrors, [.connectivity])
 ===============================================
 
 The impementation so far is this
 
 func test_load_deliversErrorOnClientError() {
     let (sut, client) = makeSUT()
     let clientError = NSError(domain: "Test", code: 0)

     var capturedErrors = [RemoteFeedLoader.Error]()
     sut.load { capturedErrors.append($0) }
          
     XCTAssertEqual(capturedErrors, [.connectivity])
 }
 
 But does not reflect the async nature of HTTPClient. So, we have to capturing data instead of stubbing them with some behaviour. So we want to capture the completion block in HTTPClientSpy( var completions and complete func)
 
 private class HTTPClientSpy: HTTPClient {
     var requestedURLs = [URL]()
     var completions = [(Error) -> Void]()

     func get(from url: URL, completion: @escaping(Error) -> Void) {
         completions.append(completion) //!!!!!
         requestedURLs.append(url)
     }
     
     func complete(with error: Error, at index: Int = 0) {
         completions[index](error)
     }
 }
 With the    completions.append(completion), i no longer stub the HTTPClientSpy, but now i capture values.
 
 So, the Arrange, Act and Assert portions of our test are transformed to this:
 
 Arrange(Given the sut and its HTTPSpy. No stubbing this time.:
 let (sut, client) = makeSUT()
  
 Act: When we tell the sut to load(invoke the behaviour that we want to test) and we complete the clients HTTP request with an error:
 
 var capturedErrors = [RemoteFeedLoader.Error]()
 sut.load { capturedErrors.append($0) }
 let clientError = NSError(domain: "Test", code: 0)
 client.complete(with: clientError)
 
 Assert: We expect the captured load error to be the connectivity error
 XCTAssertEqual(capturedErrors, [.connectivity])
 
 Syntax that i had not understand!!!! :
 
 private class HTTPClientSpy: HTTPClient {
     var requestedURLs = [URL]()
     var completions = [(Error) -> Void]()//array of functions!!!

     func get(from url: URL, completion: @escaping(Error) -> Void) {
         completions.append(completion)
         requestedURLs.append(url)
     }
     
     func complete(with error: Error, at index: Int = 0) {
         completions[index](error)//function that calls
         //the completions[index] function, passing the error object!!!!!
     }
 }
 */

