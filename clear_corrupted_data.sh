#!/bin/bash
# Script to clear corrupted UserDefaults data for Pockets app

echo "This script will clear potentially corrupted UserDefaults data for the Pockets app."
echo "Warning: This will delete your recurring expenses data."
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."

# Find the bundle identifier - try common variations
BUNDLE_ID="evank-wc.Pockets"

# Clear the recurring expenses data
defaults delete $BUNDLE_ID recurringExpenses 2>/dev/null || echo "No recurringExpenses key found"

# Synchronize UserDefaults
defaults sync $BUNDLE_ID 2>/dev/null || echo "Could not sync UserDefaults"

echo ""
echo "✅ Corrupted data cleared. You can now try running the app again."
echo "Note: If you're using the simulator, you may need to reset it:"
echo "  Device > Erase All Content and Settings"

