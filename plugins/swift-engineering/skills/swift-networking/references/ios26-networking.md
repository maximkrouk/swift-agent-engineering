# iOS 26+ Structured Concurrency Networking

## NetworkConnection vs NWConnection

| Feature | NWConnection | NetworkConnection |
|---------|--------------|-------------------|
| Async model | Completion handlers | async/await |
| State updates | `stateUpdateHandler` | `states` AsyncSequence |
| Memory | Requires `[weak self]` | No weak self needed |
| Framing | Manual | TLV built-in |
| Codable | Manual JSON | Coder protocol |

## Basic NetworkConnection

```swift
let connection: NetworkConnection = .init(
	to: .hostPort(host: "api.example.com", port: 443)
) {
	TLS()  // TCP and IP inferred
}

func communicate() async throws {
	try await connection.send(Data("Hello".utf8))
	let response = try await connection.receive(exactly: 100).content
}
```

## State Monitoring

```swift
Task {
	for await state in connection.states {
		switch state {

		case .preparing:
			self.updateStatus("Connecting...")

		case let .waiting(error):
			self.updateStatus("Waiting: \(error)")

		case .ready:
			await self.startCommunication()

		case let .failed(error):
			self.handleError(error)

		case .cancelled:
			self.handleCancellation()

		@unknown default: break
		}
	}
}
```

## TLV Framing

TCP doesn't preserve message boundaries. TLV (Type-Length-Value) solves this:

```swift
enum GameMessage: Int {
	case character = 0
	case move = 1
}

let connection: NetworkConnection = .init(to: endpoint) {
	TLV { TLS() }
}

// Send typed message
let data: Data = try JSONEncoder().encode(character)
try await connection.send(data, type: GameMessage.character.rawValue)

// Receive typed message
let (data, metadata) = try await connection.receive()
switch GameMessage(rawValue: metadata.type) {

case .character: // decode character

case .move: // decode move

case .none:
	self.handleUnknownType()
}
```

## Coder Protocol

Eliminates JSON boilerplate:

```swift
enum GameMessage: Codable {
	case character(String)
	case move(row: Int, column: Int)
}

let connection: NetworkConnection = .init(to: endpoint) {
	Coder(GameMessage.self, using: .json) { TLS() }
}

// Send Codable directly
try await connection.send(GameMessage.character("warrior"))

// Receive Codable directly
let message = try await connection.receive().content  // Returns GameMessage!
```

## NetworkListener

```swift
try await NetworkListener {
	Coder(GameMessage.self, using: .json) { TLS() }
}.run { connection in
	for try await (message, _) in connection.messages {
		// Handle each message
	}
}
```

## NetworkBrowser (Wi-Fi Aware)

```swift
import WiFiAware

let endpoint: NetworkBrowser = try await .init(
	for: .wifiAware(.connecting(to: .allPairedDevices, from: .myService))
).run { endpoints in
	.finish(endpoints.first!)
}

let connection: NetworkConnection = .init(to: endpoint) { TLS() }
```

## Receive Variants

```swift
try await connection.receive(exactly: 100).content
try await connection.receive(atLeast: 1, atMost: 1000).content
try await connection.receive(as: UInt32.self).content  // Network byte order
```

## Migration from NWConnection

```swift
// Before (NWConnection)
connection.stateUpdateHandler = { [weak self] state in
	if case .ready = state { self?.sendData() }
}
func sendData() {
	connection.send(content: data, completion: .contentProcessed { [weak self] _ in
		self?.receiveData()
	})
}

// After (NetworkConnection)
Task {
	for await state in connection.states {
		if case .ready = state {
			try await connection.send(data)
			let response = try await connection.receive(exactly: 100).content
		}
	}
}
```
