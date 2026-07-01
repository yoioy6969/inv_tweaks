/*
i_t_imm=true
i_t_list=false
i_t_cols=5
i_t_hide_imgs=true
i_t_font_size=10
i_t_offhand=true
*/
/*******************************************************************************************************************
												UTIL              
*******************************************************************************************************************/
string[int] OPTS = {"sell","sellbot","smash","smashbot","use","display","closet","mall"};

///ITEM AMOUNT AINT WERKIN RITE
///LOL NVM

void mail_list(item[int] lst, string rec) {
	string std_pt = "sendmessage.php?action=send&contact=0&message=&sendmeat=0&towho=" + rec + "&pwd=" + my_hash();
	string out = "";
	int t_cnt = 1;
	for(int i = 0; i < lst.count(); i++) {
		//print(item_amount(lst[i]), "orange");
		out += "&whichitem" + t_cnt + "=" + to_int(lst[i]) + "&howmany" + t_cnt + "=" + item_amount(lst[i]);
		if(t_cnt++ == 11) {
			t_cnt = 1;
			visit_url(std_pt + out);
			//print(out);
			out = "";
		}
	}
	//print(out);
	if(out != "")
		visit_url(std_pt + out);
	
}
void perform_opt(string opt, string[int] list) {
	item[int] it_lst;
	foreach i, ln in list
		it_lst[i] = to_item(to_int(ln)); 
		
	switch(opt) {
		case "1337":
			print("testing", "red");
			foreach i, it in it_lst {
				print(i);
				print(to_item(to_int(it)));
			}
			break;
		case "0":
			foreach i, it in it_lst 
				it.autosell(item_amount(it));
			break;
		case "1":
			it_lst.mail_list("sellbot");
			break;
		case "2":
			foreach i, it in it_lst 
				visit_url("craft.php?action=pulverize&mode=smith&smashitem=" + to_int(it) + "&qty=" + item_amount(it) + "&pwd=" + my_hash());
			break;
		case "3":
			it_lst.mail_list("smashbot");
			break;
		case "4":
			foreach i, it in it_lst 
				it.use(item_amount(it));
			break;
		case "5":
			foreach i, it in it_lst 
				it.put_display(item_amount(it));
			break;
		case "6":
			foreach i, it in it_lst 
				it.put_closet(item_amount(it));
			break;		
		case "7":
			foreach i, it in it_lst 
				put_shop(0,0,it);
			break;
	}
}
boolean value_in_list(string[int] ref, string val) {
	foreach i, ln in ref
		if(ln == val)
			return true;
	return false;
}
void append_list_to_file_set(string opt, string[int] lns) {
	string fn = "inv_tweaks/" + OPTS[to_int(opt)] + "_list.txt";
	string[int] f_contents = {};
	file_to_map(fn, f_contents);
	foreach i, ln in lns 
		if(!(f_contents.value_in_list(ln)))
			f_contents[f_contents.count()] = ln;
	f_contents.map_to_file(fn);
}
void run_all_lists() {
	for(int i = 0; i < OPTS.count(); i++) {
		string[int] f_contents = {};
		file_to_map("inv_tweaks/" + OPTS[i] + "_list.txt", f_contents);
		perform_opt(i, f_contents);
	}
}
/*******************************************************************************************************************/



/*******************************************************************************************************************
												MAIN
*******************************************************************************************************************/
string ELE_COLOR = "rgba(0,255,0,0.4)";
string SEL_COLOR = "rgba(0,0,255,255)";

/////FIND SOME WAY TO RELOAD PAGE AFTER OP(if you flip executing and reloading default page this should work)
/////PUTTING ON OUTFIT DUPES PANEL(DONE)
/////FIX ERROR 302
/////MAKE SELECTION MORE EFF(MIGHT SKIP FOR NOW)
/////ADD: HIDE IMAGES, FONT CTRL, COLUMN NUM, REMOVE CATEGORY SEGREGATION
/////MAKE GIT WORK
/////MAKE IT SO OFFHAND OPT IS ALWAYS THERE

void main() {	
	//FUTURE UPDATES
	/*int col_num = to_int(get_property("i_t_cols"));
	boolean hide_imgs = to_boolean(get_property("i_t_hide_imgs"));
	int font_size = to_int(get_property("i_t_font_size"));
	boolean show_offhand_opt = to_boolean(get_property("i_t_offhand"));*/
	
	print("entered inventory somehow???", "purple");
	string[string] fields = form_fields();
		
	if(fields contains "ajax") {
		visit_url().write();
		return;
	}
		
	if(fields contains "i_t_opt") {
		
		if(fields["i_t_opt"] == "8")
			run_all_lists();
		else {
			string[int] it_id_lst;
			
			foreach k, v in fields
				if(k.contains_text("i_t_id"))
					it_id_lst[it_id_lst.count()] = v;
				
			int i_t_mode = to_int(fields["i_t_mode"]);
			
			if((i_t_mode & 2) == 2) {
				append_list_to_file_set(fields["i_t_opt"], it_id_lst);
				set_property("i_t_list", "true");
			}
			else
				set_property("i_t_list", "false");
			
			if((i_t_mode & 1) == 1) {
				perform_opt(fields["i_t_opt"], it_id_lst);
				set_property("i_t_imm", "true");
			}
			else
				set_property("i_t_imm", "false");
		}
	}
	
	string std_args = "";
	foreach k, v in fields {
		if(!k.contains_text("i_t_"))
			std_args += k + "=" + v + "&";
	}
	if(std_args.length() > 0)
		std_args = std_args.substring(0, std_args.length()-1);

	string std_res = visit_url("inventory.php?" + std_args);
	
	//should imply that visit_url uses base page and not the script modified one
	if(std_res.contains_text("i_t_imm"))
		print("true");
	
	string def_imm = (get_property("i_t_imm")=="true")?"checked":"";
	string def_list = (get_property("i_t_list")=="true")?"checked":"";
	
	string force_font_adj = "";
	string force_img_strip = "";
	string force_col_num = "";
	
	//sell is set as 1337 from 0 for testing
	string inv_tweaks_html = "<style>*{-webkit-user-select:none;-ms-user-select:none;user-select:none;}a.i_t_enabled{color:black;}a.i_t_disabled{color:grey;pointer-events:none;}</style><table id=\"i_t_control_panel\" style=\"font-size: 12px;\"><tr><td><a href=# class=\"i_t_disabled\" onclick=\"i_t_build_and_post_form(0)\">sell</a></td><td><a href=# class=\"i_t_disabled\" onclick=\"i_t_build_and_post_form(2)\">smash</a></td><td><a href=# class=\"i_t_disabled\" onclick=\"i_t_build_and_post_form(5)\">display</a></td><td><a href=# class=\"i_t_disabled\" onclick=\"i_t_build_and_post_form(4)\">use</a></td></tr><tr><td><a href=# class=\"i_t_disabled\" onclick=\"i_t_build_and_post_form(1)\">sellbot</a></td><td><a href=# class=\"i_t_disabled\" onclick=\"i_t_build_and_post_form(3)\">smashbot</a></td><td><a href=# class=\"i_t_disabled\" onclick=\"i_t_build_and_post_form(6)\">closet</a></td><td><a href=# class=\"i_t_disabled\" onclick=\"i_t_build_and_post_form(7)\">mall</a></td></tr><tr><td></td><td><label for=\"i_t_imm_box\">imm:</label><input type=\"checkbox\" id=\"i_t_imm_box\" %1$s /></td><td><label for=\"i_t_list_box\">list:</label><input type=\"checkbox\" id=\"i_t_list_box\" %2$s /></td></tr><tr><td></td><td colspan=\"2\" style=\"text-align: center;\"><a style=\"text-align: right;\" href=# onclick=\"i_t_build_and_post_form(8)\" >run all lists</a></td></tr></table>".replace_string("%1$s",def_imm).replace_string("%2$s",def_list);
	
	//string inv_tweaks_code = file_to_buffer("inv_tweaks_new_js.js").replace_string("%1$s",SEL_COLOR).replace_string("%2$s",ELE_COLOR);
	string inv_tweaks_code = "<script>window.addEventListener(\"mousedown\",i_t_dn);window.addEventListener(\"mouseup\",i_t_up);window.addEventListener(\"mousemove\",i_t_mv);window.addEventListener(\"keyup\",((e)=>{if(e.key==\"Control\")k_a=false;}));window.addEventListener(\"keydown\",((e)=>{if(e.key==\"Control\")k_a=true;}));window.addEventListener(\"resize\",i_t_init_c);const g = 5;var c=document.createElement(\"canvas\");var i_x,i_y;var m_a=false;var c_a=false;var k_a=false;var all_es=[];var es=[];i_t_init_c();i_t_add_ctrl_pan();function i_t_init_c(){c.height=window.innerHeight;c.width=window.innerWidth;c.style=\"position:fixed;top:0px;left:0px;z-index:1;border:1pxsolid#000000;\";ctx=c.getContext(\"2d\");ctx.strokeStyle=\"%1$s\";ctx.lineWidth=3;ctx.clearRect(0,0,c.width,c.height);}function i_t_dn(e){if(e.button&1!=1) return;if(i_t_in_e(document.body.getElementsByTagName(\"table\")[0],e.x,e.y,0,0)) return;if(k_a){i_t_tog_e(e.x,e.y);return;}i_t_clear_es();m_a=true;i_x=e.x;i_y=e.y;i_t_dis_pan();}function i_t_up(e){m_a=false;c_a=false;c.remove();if(es.length>0) i_t_en_pan();}function i_t_mv(e){if(!m_a)return;if(i_t_dist(i_x,i_y,e.x,e.y)<g)return;if(!c_a)document.body.appendChild(c);c_s=true;ctx.clearRect(0,0,c.width,c.height);ctx.strokeRect(i_x,i_y,e.x-i_x,e.y-i_y);i_t_set_es(Math.min(e.x,i_x),Math.min(e.y,i_y),Math.abs(e.x-i_x),Math.abs(e.y-i_y));}function i_t_r_i(x1,y1,w1,h1,x2,y2,w2,h2){return (y1<=y2+h2&&y2<=y1+h1&&x1<=x2+w2&&x2<=x1+w1);}function i_t_set_es(x,y,w,h){i_t_clear_es();Array.from(document.body.getElementsByClassName(\"i\")).forEach((e)=>{if(i_t_in_e(e,x,y,w,h)){es.push(e);e.style=\"background:%2$s\";}});}function i_t_in_e(e,x,y,w,h){const r=e.getBoundingClientRect();return i_t_r_i(x,y,w,h,r.x,r.y,r.width,r.height);}function i_t_tog_e(x,y){for(var i=0;i<es.length;i++)if(i_t_in_e(es[i],x,y,0,0)){es[i].style=\"background:#ffffff\";es.splice(i,1);if(es.length<1) i_t_dis_pan();return;}Array.from(document.body.getElementsByClassName(\"i\")).some((e)=>{if(i_t_in_e(e,x,y,0,0)){es.push(e);e.style=\"background:%2$s\";return true;}});}function i_t_clear_es(){es.forEach((e)=>{e.style=\"background:#ffffff\"});es=[];}function i_t_en_pan(){Array.from(document.getElementsByClassName(\"i_t_disabled\")).forEach((e)=>{e.classList.remove(\"i_t_disabled\");e.classList.add(\"i_t_enabled\");});}function i_t_dis_pan(){Array.from(document.getElementsByClassName(\"i_t_enabled\")).forEach((e)=>{e.classList.remove(\"i_t_enabled\");e.classList.add(\"i_t_disabled\");});}function i_t_extract_ids() {var id_lst=[];es.forEach((e)=>{id_lst.push(/i([0-9]+)/.exec(e.getElementsByTagName(\"table\")[0].getElementsByTagName(\"tbody\")[0].getElementsByTagName(\"tr\")[0].getElementsByTagName(\"td\")[1].id)[1]);});return id_lst}function i_t_build_and_post_form(opt) {var id_lst = i_t_extract_ids();var do_imm = document.getElementById(\"i_t_imm_box\").checked;var do_lst = document.getElementById(\"i_t_list_box\").checked;var mode_val = ((do_imm)?1:0)+((do_lst)?2:0);var form_e = document.createElement(\"form\");form_e.action=\"inventory.php\";form_e.method=\"post\";var relay_e = document.createElement(\"input\");relay_e.name = \"relay\";relay_e.value = \"true\";form_e.appendChild(relay_e);var opt_e = document.createElement(\"input\");opt_e.name = \"i_t_opt\";opt_e.value = opt;form_e.appendChild(opt_e);var mode_e = document.createElement(\"input\");mode_e.name = \"i_t_mode\";mode_e.value = mode_val;form_e.appendChild(mode_e);for(var i = 0; i < id_lst.length; i++) {var it = document.createElement(\"input\");it.name = \"i_t_id\" + (i+1); it.value = id_lst[i];form_e.appendChild(it);}document.body.appendChild(form_e);form_e.submit();}function i_t_add_ctrl_pan() {const small_tds = document.body.getElementsByTagName(\"center\")[0].getElementsByTagName(\"table\")[0].getElementsByTagName(\"tbody\")[0].getElementsByTagName(\"tr\")[1].getElementsByTagName(\"td\")[0].getElementsByTagName(\"center\")[0].getElementsByTagName(\"table\")[0].getElementsByTagName(\"tbody\")[0].getElementsByTagName(\"tr\")[0].getElementsByTagName(\"td\")[0].getElementsByTagName(\"p\")[0].getElementsByTagName(\"table\")[0].getElementsByTagName(\"tbody\")[0].getElementsByTagName(\"tr\")[0].getElementsByClassName(\"small\");const panel_pos = small_tds[((small_tds.length == 3)?1:0)];panel_pos.appendChild(document.getElementById(\"i_t_control_panel\"));}function i_t_dist(x1, y1, x2, y2) {var d_x = x1 - x2;var d_y = y1 - y2;return Math.sqrt(d_x*d_x + d_y*d_y);}</script>".replace_string("%1$s",SEL_COLOR).replace_string("%2$s",ELE_COLOR);
	write(std_res + inv_tweaks_html + inv_tweaks_code);
}
/*******************************************************************************************************************/
