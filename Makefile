CFLAGS=-g
export CFLAGS

USERNAME = ''
PASSWORD = ''

.PHONY: deps clean build

deps:
	go get -u ./gitlab-connector/...

clean:
	rm -rf ./gitlab-connector/git-connector

build:
	GOOS=linux GOARCH=amd64 go build -o gitlab-connector/gitlab-connector ./gitlab-connector

test:
	go test ./gitlab-connector

deploy:
	if ! aws s3 ls "$(TARGET_BUCKET)" 2> /dev/null; then aws s3 mb s3://$(TARGET_BUCKET); fi
	aws cloudformation package --template-file ./template.yaml --s3-bucket $(TARGET_BUCKET) --output-template-file packaged-template.yaml
	aws cloudformation deploy --template-file ./packaged-template.yaml --stack-name "GitLabConnector" --parameter-overrides BucketName=$(TARGET_BUCKET) Username=$(USERNAME) Password=$(PASSWORD) ApiKey="$(API_KEY)" --capabilities CAPABILITY_IAM --region $(AWS_DEFAULT_REGION)
