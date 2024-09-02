.PHONY: all
all: test

.PHONY: test
test:
	mix format
	mix credo
	mix dialyzer
	mix test
