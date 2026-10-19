# Stargate Java gRPC Client

The Java client is currently kept in the Stargate [core repository] because the protobuf stub is
used by the server-side implementation as well as a client for tests. The `grpc-proto` module also
contains helpers for authentication and value conversion for gRPC types to and from Java types. To
use the client from your application use the following dependencies:

```xml
<dependencies>
    <dependency>
        <groupId>io.stargate.grpc</groupId>
        <artifactId>grpc-proto</artifactId>
        <version>1.0.40</version>
    </dependency>
    <dependency>
         <groupId>io.grpc</groupId>
         <artifactId>grpc-netty-shaded</artifactId>
         <version>1.40.1</version>
    </dependency>
</dependencies>
```

## Getting Started

The core repository also has information for [getting started] with the gRPC client for Java.

[core repository]: https://github.com/stargate/stargate/tree/master/grpc-proto
[getting started]: https://github.com/stargate/stargate/tree/master/grpc-examples

