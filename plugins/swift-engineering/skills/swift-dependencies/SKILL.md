---
name: swift-dependencies
description: Use when building features, and implementing services that support injection using swift-dependencies.
---
# swift-dependencies

Dependencies are the types and functions in the application that need to interact with outside systems that are not in control of the current context. Classic examples of this are API clients that make network requests to servers, but also seemingly innocuous things such as `UUID` and `Date` initializers, file access, user defaults, and even clocks and timers, can all be thought of as dependencies.

One can get really far in application development without ever thinking about dependency management (or, as some like to call it, “dependency injection”), but eventually uncontrolled dependencies can cause many problems in the code base and development cycle:

- Uncontrolled dependencies make it **difficult to write fast, deterministic tests** because code is susceptible to the vagaries of the outside world, such as file systems, network connectivity, internet speed, server uptime, and more.
    
- Many dependencies **do not work well in SwiftUI previews**, such as location managers and speech recognizers, and some **do not work even in simulators**, such as motion managers, and more. This prevents one from being able to easily iterate on the design of features if one makes use of those frameworks.
    
- Dependencies that interact with 3rd party, non-Apple libraries (such as Firebase, web socket libraries, network libraries, etc.) tend to be heavyweight and take a **long time to compile**. This can slow down development cycle.
    

For these reasons, and a lot more, it is highly encouraged to take control of dependencies rather than letting them control you.

But, controlling a dependency is only the beginning. Once you have controlled your dependencies, you are faced with a whole set of new problems:

- How can **dependencies be propagated** throughout your entire application in a way that is more ergonomic than explicitly passing them around everywhere, but safer than having a global dependency?
    
- How one **override dependencies** for just one portion of the application? This can be handy for overriding dependencies for tests and SwiftUI previews, as well as specific user flows such as onboarding experiences.
    
- How can one be sure to **overrode _all_ dependencies** a feature uses in tests? It would be incorrect for a test to mock out some dependencies but leave others as interacting with the outside world.
    

This library addresses all of the points above, and much, _much_ more.

## Reference Loading Guide

**ALWAYS load reference files if there is even a small chance the content may be required.** It's better to have the context than to miss a pattern or make a mistake.

| Reference                                                | Load When                                                                         |
| -------------------------------------------------------- | --------------------------------------------------------------------------------- |
| **[Reducer Structure](references/reducer-structure.md)** | Creating new reducers, setting up `@Reducer`, `State`, `Action`, or `@ViewAction` |


