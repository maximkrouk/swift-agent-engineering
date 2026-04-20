
### Access dependencies


### Predefined dependencies

- `assert`
	A dependency for handling assertions (reports issue in testing context instead of terminating of executable)
- `assertionFailure`
	A dependency for failing an assertion (reports issue in testing context instead of terminating of executable)
- `precondition`
	A dependency for handling precondition (reports issue in testing context instead of terminating of executable)
- `calendar`
	The current calendar that features should use when handling dates (reports issue in testing contexts, is expected to be overridden in tests)
- `continuousClock`
	The current clock that features should use when a `ContinuousClock` would be appropriate (unimplemented in testing contexts, is expected to be overridden with `TestClock` of `ImmediateClock` from `pointfreeco/swift-clocks` in tests)
- `suspendingClock`
	The current clock that features should use when a `SuspendingClock` would be appropriate (unimplemented in testing contexts, is expected to be overridden with `TestClock` of `ImmediateClock` from `pointfreeco/swift-clocks` in tests)
- `context`
	The current ``DependencyContext`` can be used to determine how dependencies are loaded by the runtime
- `date`
	A dependency that returns the current date (is expected to be overridden in tests)
- `fireAndForget`
	A dependency for firing off an unstructured task (falls back to structured in testing contexts)
- `locale`
	The current locale that features should use (reports issue in testing contexts, is expected to be overridden in tests)
- `mainQueue`
	The "main" queue scheduler (is expected to be overriden with `DispatchQueue.test.eraseToAnyScheduler()` in tests)
- `mainRunLoop`
	The "main" run loop scheduler (is expected to be overriden with `RunLoop.test.eraseToAnyScheduler()` in tests)
- `notificationCenter`
	The notification center that features should use (`NotificationCenter.default` by default, task-local center in tests)
- `openURL`
	A dependency that opens a URL (is expected to be overriden in tests)
- `timeZone`
	The current time zone that features should use when handling dates (reports issue in testing contexts, is expected to be overridden in tests)
- `urlSession`
	The URL session that features should use to make URL requests (reports issue in testing contexts, is expected to be overridden in tests)
- `uuid`
	A dependency that generates UUIDs (is expected to be overriden in tests)
- `withRandomNumberGenerator`
	A dependency that yields a random number generator to a closure (is expected to be overriden in tests)
	