# Used by tab_title_template's {custom}: a coloured dot per Claude Code state.
from kitty.fast_data_types import get_boss

COLORS = {'attention': 'red', 'busy': 'yellow', 'idle': 'green'}
PRIORITY = ('attention', 'busy', 'idle')


def draw_title(data):
    tab = get_boss().tab_for_id(data['tab_id'])
    if tab is None:
        return ''
    states = {w.user_vars.get('claude_state') for w in tab}
    for state in PRIORITY:
        if state in states:
            fmt = data['fmt']
            return f'{getattr(fmt.fg, COLORS[state])}●{fmt.fg.tab} '
    return ''
