#!/bin/zsh

# Have only backticks

hidutil property --set '{
  "UserKeyMapping": [
    {
      "HIDKeyboardModifierMappingSrc": 0x700000064,
      "HIDKeyboardModifierMappingDst": 0x700000035
    }
  ]
}' > /tmp/remapkeys.log

# Swap backticks and math symbols

# hidutil property --set '{
#   "UserKeyMapping": [
#     {
#       "HIDKeyboardModifierMappingSrc": 0x700000064,
#       "HIDKeyboardModifierMappingDst": 0x700000035
#     },
#     {
#         "HIDKeyboardModifierMappingSrc": 0x700000035,
#         "HIDKeyboardModifierMappingDst": 0x700000064
#     }
#   ]
# }' > /tmp/remapkeys.log
