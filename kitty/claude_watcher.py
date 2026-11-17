# Redraw the tab bar when a window's claude_state user var changes.
def on_set_user_var(boss, window, data):
    if data.get('key') == 'claude_state':
        tab = window.tabref()
        if tab is not None:
            tab.mark_tab_bar_dirty()
