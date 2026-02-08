.PHONY: check dod validate check-all dod-all

# ---------------------------------------------------------------------------
# Parent workspace targets — orchestrate backend + frontend
# ---------------------------------------------------------------------------

# Run all checks in both repos
check-all:
	@echo "=== Backend ==="
	@$(MAKE) -C backend check
	@echo ""
	@echo "=== Frontend ==="
	@$(MAKE) -C frontend check
	@echo ""
	@echo "✓ All checks passed in both repos."

# Run DoD checks in both repos
dod-all:
	@echo "=== Backend DoD ==="
	@$(MAKE) -C backend dod
	@echo ""
	@echo "=== Frontend DoD ==="
	@$(MAKE) -C frontend dod
	@echo ""
	@echo "✓ All DoD checks passed in both repos."

# Pre-merge validation for a specific change
# Usage: make validate CHG=CHG-011
validate:
ifndef CHG
	@echo "Usage: make validate CHG=CHG-NNN"
	@echo "Example: make validate CHG=CHG-011"
	@exit 1
endif
	@./scripts/validate_change.sh $(CHG)

# Convenience aliases
check: check-all
dod: dod-all
