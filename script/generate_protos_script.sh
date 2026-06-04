
# Get the current script's directory
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to one level upper
cd "$script_dir/.."

# Now, you are in the directory one level upper
pwd

apiPath="/Users/user/Desktop/money-management-api-master/money-management-api/src/main/protobuf"

protoc --proto_path=$apiPath --dart_out=grpc:data/lib/src/service/protobuf $apiPath/de/gebit/rp/money/management/service/v1/service/money_management_service.proto
protoc --proto_path=$apiPath --dart_out=grpc:data/lib/src/service/protobuf $apiPath/de/gebit/rp/money/management/service/v1/query/money_management_query.proto
protoc --proto_path=$apiPath --dart_out=grpc:data/lib/src/service/protobuf $apiPath/de/gebit/rp/money/management/service/v1/event/money_management_event.proto
protoc --proto_path=$apiPath --dart_out=grpc:data/lib/src/service/protobuf $apiPath/de/gebit/rp/money/management/service/v1/datatype/money_management_datatype.proto
protoc --proto_path=$apiPath --dart_out=grpc:data/lib/src/service/protobuf $apiPath/de/gebit/rp/money/management/service/v1/command/money_management_command.proto

##Goggle
protoc --proto_path=$apiPath --dart_out=grpc:data/lib/src/service/protobuf $apiPath/google/type/date.proto
protoc --proto_path=$apiPath --dart_out=grpc:data/lib/src/service/protobuf $apiPath/google/protobuf/empty.proto
protoc --proto_path=$apiPath --dart_out=grpc:data/lib/src/service/protobuf $apiPath/google/protobuf/timestamp.proto
protoc --proto_path=$apiPath --dart_out=grpc:data/lib/src/service/protobuf $apiPath/google/protobuf/wrappers.proto
