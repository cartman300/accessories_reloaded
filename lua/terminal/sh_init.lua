Terminal = Terminal or {};

T_COL_NIL = 0;
T_COL_MSG = 1;
T_COL_WRN = 2;
T_COL_ERR = 3;
T_COL_INFO = 4;
T_COL_INTL = 5;
T_COL_CMD = 6;
T_COL_SUCC = 7;

function Terminal:ColorFromIndex(code)
	if (code == T_COL_MSG) then
		return Color(200, 200, 200);
	elseif (code == T_COL_WRN) then
		return Color(255, 250, 50);
	elseif (code == T_COL_ERR) then
		return Color(255, 50, 50);
	elseif (code == T_COL_INFO) then
		return Color(60, 100, 250);
	elseif (code == T_COL_INTL) then
		return Color(60, 250, 250);
	elseif (code == T_COL_CMD) then
		return Color(125, 125, 125);
	elseif (code == T_COL_SUCC) then
		return Color(75, 255, 80);
	end;

	return Color(50, 50, 50);
end;