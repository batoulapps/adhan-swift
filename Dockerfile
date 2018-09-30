FROM swift:4.2

WORKDIR /package

COPY . ./

RUN swift package resolve
RUN swift package clean
RUN swift test