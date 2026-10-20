.PHONY: all

test_targets := $(sort $(notdir $(basename $(wildcard *.py))))


all:
	$(MAKE) $(test_targets)

%:
	@uv run --project ../.. python -m unittest -v $@


