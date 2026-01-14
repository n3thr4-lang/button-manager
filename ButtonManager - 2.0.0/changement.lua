--[[
================================================================================
ButtonManager – Change Log
Author: nethra
================================================================================

Version: Pre-release (Refactor milestone)

SUMMARY
-------
This update focuses on restructuring the ButtonManager into a more modular,
state-aware, and extensible system. The previous monolithic implementation
has been split into clear responsibilities, improving maintainability and
future scalability.

--------------------------------------------------------------------------------
KEY CHANGES
--------------------------------------------------------------------------------

1. State System Introduced
-------------------------
- Added a dedicated state table per button.
- Each button now tracks:
    - enabled
    - toggled
    - holding
    - last_activation
    - last_hold
    - last_release
- State is no longer inferred implicitly from events.
- Snapshot copies are provided to operators to prevent external mutation.

2. Callback Architecture Refactor
---------------------------------
- Button behavior logic has been extracted into a separate callbacks module.
- button_function now handles:
    - single_press
    - hold
    - toggle
    - long_press
- interaction_hooks now handle:
    - enter
    - leave
    - down
    - up
    - on_toggle
- This separation allows adding new interaction types without modifying
  the core ButtonManager class.

3. Cache and Cleanup Improvements
---------------------------------
- All RBXScriptConnections and running threads are stored per button key.
- disable_button() now safely disconnects:
    - RBXScriptConnections
    - task threads
- Button destruction is automatically handled via Destroying connections.

4. Button-to-Key Mapping
------------------------
- Introduced a reverse lookup table (button_to_key).
- Functions now accept either:
    - button key (string)
    - GuiButton instance
- Improves API ergonomics and reduces boilerplate for consumers.

5. Visibility and Reset Handling
--------------------------------
- toggle_visibility() supports:
    - single button
    - all registered buttons
- Optional state reset added via config.reset_state.
- Visibility defaults are preserved unless explicitly overridden.

6. API Behavior Changes
-----------------------
- Activate_button() now:
    - Validates button existence and type
    - Clears previous connections before reactivation
    - Applies interaction hooks dynamically based on operator table
- remove_button() fully cleans:
    - state
    - cache
    - reverse mappings

7. Legacy Code Removed
----------------------
- Removed older inline button_function and interaction_hooks implementations.
- Eliminated unused or partially implemented concepts (e.g. cooldown, busy).
- Reduced duplicated logic across versions.

--------------------------------------------------------------------------------
NOTES
--------------------------------------------------------------------------------
- This refactor prioritizes clarity and long-term extensibility over minimalism.
- Future features such as cooldowns or disabled states can be added cleanly
  on top of the existing state system.
- Public API is now stable enough for external usage and documentation.

================================================================================
End of Change Log
================================================================================
]]
