; Leet Chat
; Copyright © 2011 Henry++
;
; GNU General Public License v2
; http://www.gnu.org/licenses/
;
; http://www.henrypp.org/

#NoTrayIcon

#include "Constants.au3"
#include "ButtonConstants.au3"
#include "GUIConstants.au3"
#include "GUIEdit.au3"
#include "GuiImageList.au3"
#include "GUIListView.au3"
#include "MenuConstants.au3"
#include "Misc.au3"
#include "StaticConstants.au3"
#include "WindowsConstants.au3"

;Application Constants
Global $application = "Leet Chat"
Global $version = "1.0 build 1061 Beta"
Global $homepage = "http://www.henrypp.org/"
Global $settings_file = @ScriptDir &"\leetchat.ini"
Global $files_dir = @ScriptDir &"\files"
Global $sounds_dir = @ScriptDir &"\sounds"
Global $cipher_key = 5*100+55
Global $server_port = 50505

;Mutex
Global $server_mutex = "LEET_SERVER"

;Sounds
Global $alarm_snd = $sounds_dir &"\Alarm.wav"
Global $send_snd = $sounds_dir &"\Send.wav"
Global $recieve_snd = $sounds_dir &"\Recieve.wav"

;Client / Server
Global $server = -1, $server_pswd = "", $server_name = "", $server_ip = "", $chat_log = "", $server_log = "", $server_log_old = $server_log, $max_clients = "", $connected = 0, $connected_old = $connected

;Other Constants
Global $send_edit, $send_btn, $convert_text_btn

Opt("TrayMenuMode", 1)
TraySetClick(16)

TCPStartup()

_ActionDlg(1)

Func _ActionDlg($iMode = 1)
	Global $action_dlg = GUICreate("Клиент", 324, 225, -1, -1, -1, $WS_EX_TOPMOST)
	GUISetIcon(@ScriptFullPath, -1)

	GUICtrlCreateGroup("", 10, 5, 304, 177)
	DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle(-1), "wstr", "", "wstr", "")

	Local $close_btn = GUICtrlCreateButton("Закрыть", 240, 192, 75, 25, -1, $WS_EX_STATICEDGE)
	DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle(-1), "wstr", "", "wstr", "")

	;Client
	Global $server_label_1 = GUICtrlCreateLabel("Адрес сервера:", 25, 25, 175, 15)
	Global $server_input_1 = GUICtrlCreateInput(IniRead($settings_file, "Client", "LastServer", @IPAddress1), 25, 45, 175, 21)
	DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle(-1), "wstr", "", "wstr", "")

	Global $port_label_1 = GUICtrlCreateLabel("Порт:", 210, 25, 89, 15)
	Global $port_input_1 = GUICtrlCreateInput(IniRead($settings_file, "Client", "LastPort", $server_port), 210, 45, 89, 21)
	DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle(-1), "wstr", "", "wstr", "")

	Global $name_label_1 = GUICtrlCreateLabel("Имя пользователя:", 25, 75, 273, 15)
	Global $name_input_1 = GUICtrlCreateInput(IniRead($settings_file, "Client", "LastName", @UserName), 25, 95, 273, 21)
	DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle(-1), "wstr", "", "wstr", "")

	Global $password_label_1 = GUICtrlCreateLabel("Пароль:", 25, 125, 273, 15)
	Global $password_input_1 = GUICtrlCreateInput(_nCrypt(IniRead($settings_file, "Client", "LastPassword", ""), $cipher_key), 25, 145, 273, 21)
	DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle(-1), "wstr", "", "wstr", "")

	Global $server_btn = GUICtrlCreateButton("Сервер", 10, 192, 75, 25, -1, $WS_EX_STATICEDGE)
	DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle(-1), "wstr", "", "wstr", "")
	If _OpenMutex($server_mutex) Then GUICtrlSetState(-1, $GUI_DISABLE)

	Global $connect_btn = GUICtrlCreateButton("Соединиться", 160, 192, 75, 25, -1, $WS_EX_STATICEDGE)
	DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle(-1), "wstr", "", "wstr", "")
	GUICtrlSetState(-1, $GUI_DEFBUTTON)

	;Server
	Global $server_label_2 = GUICtrlCreateLabel("Адрес сервера:", 25, 25, 175, 15)
	GUICtrlSetState(-1, $GUI_HIDE)
	Global $server_input_2 = GUICtrlCreateCombo("", 25, 45, 175, 21)
	DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle(-1), "wstr", "", "wstr", "")
	GUICtrlSetData(-1, @IPAddress1 &"|"& @IPAddress2, @IPAddress1)
	GUICtrlSetState(-1, $GUI_HIDE)

	Global $port_label_2 = GUICtrlCreateLabel("Порт:", 210, 25, 89, 15)
	GUICtrlSetState(-1, $GUI_HIDE)
	Global $port_input_2 = GUICtrlCreateInput(IniRead($settings_file, "Server", "LastPort", $server_port), 210, 45, 89, 21)
	DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle(-1), "wstr", "", "wstr", "")
	GUICtrlSetState(-1, $GUI_HIDE)

	Global $name_label_2 = GUICtrlCreateLabel("Имя сервера:", 25, 75, 175, 15)
	GUICtrlSetState(-1, $GUI_HIDE)
	Global $name_input_2 = GUICtrlCreateInput(IniRead($settings_file, "Server", "LastName", "Leet Server"), 25, 95, 175, 21)
	DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle(-1), "wstr", "", "wstr", "")
	GUICtrlSetState(-1, $GUI_HIDE)

	Global $users_label_2 = GUICtrlCreateLabel("Клиентов:", 210, 75, 89, 15)
	GUICtrlSetState(-1, $GUI_HIDE)
	Global $users_input_2 = GUICtrlCreateInput(IniRead($settings_file, "Server", "LastMaxClients", 10), 210, 95, 89, 21)
	DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle(-1), "wstr", "", "wstr", "")
	GUICtrlSetState(-1, $GUI_HIDE)

	Global $password_label_2 = GUICtrlCreateLabel("Пароль:", 25, 125, 273, 15)
	GUICtrlSetState(-1, $GUI_HIDE)
	Global $password_input_2 = GUICtrlCreateInput(_nCrypt(IniRead($settings_file, "Server", "LastPassword", ""), $cipher_key), 25, 145, 273, 21)
	DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle(-1), "wstr", "", "wstr", "")
	GUICtrlSetState(-1, $GUI_HIDE)

	Global $client_btn = GUICtrlCreateButton("Клиент", 10, 192, 75, 25, -1, $WS_EX_STATICEDGE)
	DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle(-1), "wstr", "", "wstr", "")
	GUICtrlSetState(-1, $GUI_HIDE)

	Global $create_btn = GUICtrlCreateButton("Создать", 160, 192, 75, 25, -1, $WS_EX_STATICEDGE)
	DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle(-1), "wstr", "", "wstr", "")
	GUICtrlSetState(-1, $GUI_HIDE)

	GUISetState(@SW_SHOW)
	
	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE, $close_btn
				GUIDelete($action_dlg)
				ExitLoop
			Case $GUI_EVENT_PRIMARYDOWN
				_SendMessage($action_dlg, $WM_SYSCOMMAND, BitOR($SC_MOVE, $HTCAPTION), 0)
			Case $server_btn
				_SaveAction(1)
				_SwitchAction(2)
			Case $client_btn
				_SaveAction(2)
				_SwitchAction(1)
			Case $connect_btn
				Local $server_data = GUICtrlRead($server_input_1), $port_data = GUICtrlRead($port_input_1), $name_data = GUICtrlRead($name_input_1), $password_data = GUICtrlRead($password_input_1)
				
				If $server_data = "" Then
					MsgBox(16 + 262144, "Ошибка", "Необходимо ввести адрес сервера", -1, $action_dlg)
				ElseIf $port_data = "" Then
					MsgBox(16 + 262144, "Ошибка", "Необходимо ввести порт сервера", -1, $action_dlg)
				ElseIf $name_data = "" Then
					MsgBox(16 + 262144, "Ошибка", "Необходимо ввести ник", -1, $action_dlg)
				Else
					Local $ip_data = TCPNameToIP($server_data)
					
					Ping($ip_data)
					
					If not @error Then
						$server = TcpConnect($ip_data, $port_data)
						If $server = -1 or $server = 0 or @error Then
							If @error = 1 Then
								MsgBox(16 + 262144, "Ошибка", "Введён неверный IP адрес", -1, $action_dlg)
							ElseIf @error = 2 Then
								MsgBox(16 + 262144, "Ошибка", "Введён неверный порт", -1, $action_dlg)
							Else
								MsgBox(16 + 262144, "Ошибка", "Не удалось подключиться к серверу", -1, $action_dlg)
							EndIf
						Else
							$server_ip = $ip_data
							
							_SaveAction(1)

							TcpSend($server, _EncodeText('<username="'& _ConvertStringToBinary($name_data) &'" password="'& _ConvertStringToBinary($password_data) &'" client="'& _ConvertStringToBinary($version) &'" action="'& _ConvertStringToBinary("authorization") &'">'))
							
							Do
								Sleep(15)
								$tcp_recv_enc = TcpRecv($server, 1000000)
								$tcp_recv = _DecodeText($tcp_recv_enc)
							Until $tcp_recv <> ""

							If _GetValueFromString($tcp_recv, "action") = "authorization" Then
								Local $response_expand = _GetValueFromString($tcp_recv, "response")

								If $response_expand = "invalid_password" Then
									MsgBox(16 + 262144, "Ошибка", "Неправильный пароль для доступа на сервер", -1, $action_dlg)
								ElseIf $response_expand = "server_overflow" Then
									MsgBox(16 + 262144, "Ошибка", "Сервер переполнен", -1, $action_dlg)
								ElseIf $response_expand = "username_already_exists" Then 
									MsgBox(16 + 262144, "Ошибка", 'Пользователь с ником "'& $name_data & '" уже присутствует на сервере', -1, $action_dlg)
								ElseIf $response_expand = "connection_accepted" Then
									$server_name = _GetValueFromString($tcp_recv, "server_name") 
									$max_clients = _GetValueFromString($tcp_recv, "max_clients") 
									
									GUIDelete($action_dlg)
									
									_CreateChat($server, $name_data)
									
									ExitLoop
								EndIf
							EndIf
						EndIf
					Else
						MsgBox(16 + 262144, "Ошибка", "Не удалось подключиться к серверу", -1, $action_dlg)
					EndIf
				EndIf
			Case $create_btn
				Local $server_data = GUICtrlRead($server_input_2), $port_data = GUICtrlRead($port_input_2), $name_data = GUICtrlRead($name_input_2), $password_data = GUICtrlRead($password_input_2), $max_clients_data = GUICtrlRead($users_input_2)
				
				If $server_data = "" Then
					MsgBox(16 + 262144, "Ошибка", "Необходимо ввести адрес сервера", -1, $action_dlg)
				ElseIf $port_data = "" Then
					MsgBox(16 + 262144, "Ошибка", "Необходимо ввести порт сервера", -1, $action_dlg)
				ElseIf $name_data = "" Then
					MsgBox(16 + 262144, "Ошибка", "Необходимо ввести имя сервера", -1, $action_dlg)
				ElseIf $max_clients_data = "" Then
					MsgBox(16 + 262144, "Ошибка", "Необходимо ввести количество клиентов", -1, $action_dlg)
				Else
					Local $ip_data = TCPNameToIP($server_data)
					
					$server = TcpListen($ip_data, $port_data)
					If $server = -1 or @error Then
						MsgBox(16 + 262144, "Ошибка", "Не удалось создать сервер", -1, $action_dlg)
						TcpCloseSocket($server)
					Else
						_SaveAction(2)

						$server_name = $name_data
						$server_pswd = $password_data
						$server_ip = $ip_data
						$max_clients = $max_clients_data
	
						GuiDelete($action_dlg)
												
						_ServerProcessor()
						
						Exitloop
					EndIf
				EndIf
		EndSwitch
	WEnd
EndFunc

Func _SwitchAction($iState)
	Switch $iState
		Case 1 ;Client
			WinSetTitle($action_dlg, "", "Клиент")
			GUISetIcon(@ScriptFullPath, -1)
		
			GUICtrlSetState($server_label_2, $GUI_HIDE)
			GUICtrlSetState($server_input_2, $GUI_HIDE)
			GUICtrlSetState($port_input_2, $GUI_HIDE)
			GUICtrlSetState($port_input_2, $GUI_HIDE)
			GUICtrlSetState($name_label_2, $GUI_HIDE)
			GUICtrlSetState($name_input_2, $GUI_HIDE)
			GUICtrlSetState($users_label_2, $GUI_HIDE)
			GUICtrlSetState($users_input_2, $GUI_HIDE)
			GUICtrlSetState($password_label_2, $GUI_HIDE)
			GUICtrlSetState($password_input_2, $GUI_HIDE)
			GUICtrlSetState($client_btn, $GUI_HIDE)
			GUICtrlSetState($create_btn, $GUI_HIDE)
			
			GUICtrlSetState($server_label_1, $GUI_SHOW)
			GUICtrlSetState($server_input_1, $GUI_SHOW)
			GUICtrlSetState($port_input_1, $GUI_SHOW)
			GUICtrlSetState($port_input_1, $GUI_SHOW)
			GUICtrlSetState($name_label_1, $GUI_SHOW)
			GUICtrlSetState($name_input_1, $GUI_SHOW)
			GUICtrlSetState($password_label_1, $GUI_SHOW)
			GUICtrlSetState($password_input_1, $GUI_SHOW)
			GUICtrlSetState($server_btn, $GUI_SHOW)
			If _OpenMutex($server_mutex) Then GUICtrlSetState($server_btn, $GUI_DISABLE)
			GUICtrlSetState($connect_btn, $GUI_SHOW)
			
			GUICtrlSetState($connect_btn, $GUI_DEFBUTTON)
		Case 2 ;Server		
			WinSetTitle($action_dlg, "", "Сервер")
			GUISetIcon(@ScriptFullPath, -2)
			
			GUICtrlSetState($server_label_1, $GUI_HIDE)
			GUICtrlSetState($server_input_1, $GUI_HIDE)
			GUICtrlSetState($port_input_1, $GUI_HIDE)
			GUICtrlSetState($port_input_1, $GUI_HIDE)
			GUICtrlSetState($name_label_1, $GUI_HIDE)
			GUICtrlSetState($name_input_1, $GUI_HIDE)
			GUICtrlSetState($password_label_1, $GUI_HIDE)
			GUICtrlSetState($password_input_1, $GUI_HIDE)
			GUICtrlSetState($server_btn, $GUI_HIDE)
			GUICtrlSetState($connect_btn, $GUI_HIDE)
			
			GUICtrlSetState($server_label_2, $GUI_SHOW)
			GUICtrlSetState($server_input_2, $GUI_SHOW)
			GUICtrlSetState($port_input_2, $GUI_SHOW)
			GUICtrlSetState($port_input_2, $GUI_SHOW)
			GUICtrlSetState($name_label_2, $GUI_SHOW)
			GUICtrlSetState($name_input_2, $GUI_SHOW)
			GUICtrlSetState($users_label_2, $GUI_SHOW)
			GUICtrlSetState($users_input_2, $GUI_SHOW)
			GUICtrlSetState($password_label_2, $GUI_SHOW)
			GUICtrlSetState($password_input_2, $GUI_SHOW)
			GUICtrlSetState($client_btn, $GUI_SHOW)
			GUICtrlSetState($create_btn, $GUI_SHOW)
			
			GUICtrlSetState($create_btn, $GUI_DEFBUTTON)
		Case Else
			Return
	EndSwitch
EndFunc

Func _SaveAction($iState = 0)
	Switch $iState
		Case 1 ;Client
			IniWrite($settings_file, "Client", "LastServer", GuiCtrlRead($server_input_1))
			IniWrite($settings_file, "Client", "LastPort", GuiCtrlRead($port_input_1))
			IniWrite($settings_file, "Client", "LastName", GUICtrlRead($name_input_1))
			IniWrite($settings_file, "Client", "LastPassword", _nCrypt(GuiCtrlRead($password_input_1), $cipher_key))
		Case 2 ;Server				
			IniWrite($settings_file, "Server", "LastServer", GuiCtrlRead($server_input_2))
			IniWrite($settings_file, "Server", "LastPort", GuiCtrlRead($port_input_2))
			IniWrite($settings_file, "Server", "LastName", GUICtrlRead($name_input_2))
			IniWrite($settings_file, "Server", "LastMaxClients", GUICtrlRead($users_input_2))
			IniWrite($settings_file, "Server", "LastPassword", _nCrypt(GuiCtrlRead($password_input_2), $cipher_key))
		Case Else
			_SaveAction(1)
			_SaveAction(2)
	EndSwitch
EndFunc

Func _CreateChat($sServer, $sNik)
	Global $usernik = $sNik
	
	;Configure Tray menu
	TraySetState(1)
	Opt("TrayOnEventMode", 0)
	TraySetIcon(@ScriptFullPath, 100)
	TraySetToolTip($application &" "& $version &@CRLF&@CRLF& "Адрес сервера: "& $server_ip &@CRLF& "Имя сервера: "& $server_name &@CRLF& "Пользователь: "& $usernik)

	Global $main_dlg = GUICreate($application &" "& $version, 668, 465, -1, -1, -1, $WS_EX_TOPMOST)
	GUISetIcon(@ScriptFullPath, -1, $main_dlg)	
	
	;History Control
	Global $history_edit = GUICtrlCreateEdit("", 10, 10, 470, 325, $ES_MULTILINE + $ES_READONLY + $ES_AUTOVSCROLL, $WS_EX_STATICEDGE)
	_RemoveWindowTheme(-1)
	
	;Send Control
	Global $send_edit = GUICtrlCreateEdit("", 10, 363, 648, 50, $ES_NOHIDESEL + $ES_MULTILINE + $ES_AUTOVSCROLL, $WS_EX_STATICEDGE)
	_RemoveWindowTheme(-1)
	
	;Toolbar
	Global $send_btn = GUICtrlCreateButton("", 10, 338, 21, 21)
	GUICtrlSetState(-1, $GUI_DISABLE)
	
	Global $convert_text_btn = GUICtrlCreateButton("", 33, 338, 21, 21)
	GUICtrlSetState(-1, $GUI_DISABLE)
	
	_ReadSettings()
	
	;Menu
	Global $file_menu = GUICtrlCreateMenu("Файл")
	Global $save_item = GUICtrlCreateMenuItem("Сохранить историю", $file_menu)
	Global $clear_item = GUICtrlCreateMenuItem("Очистить историю", $file_menu)
	GUICtrlCreateMenuItem("", $file_menu)
	Global $exit_from_chat_item = GUICtrlCreateMenuItem("Выйти из чата", $file_menu)
	Global $exit_item = GUICtrlCreateMenuItem("Выйти", $file_menu)

	Global $settings_menu = GUICtrlCreateMenu("Настройки")
	Global $ontop_item = GUICtrlCreateMenuItem("Поверх остальных окон", $settings_menu)
	If $ontop_opt = 1 Then GUICtrlSetState($ontop_item, $GUI_CHECKED)	
	Global $usesnd_item = GUICtrlCreateMenuItem("Использовать звуки", $settings_menu)
	If $usesnd_opt = 1 Then GUICtrlSetState($usesnd_item, $GUI_CHECKED)
	GUICtrlCreateMenuItem("", $settings_menu)
	Global $send_hotkey_menu = GUICtrlCreateMenu("Клавиша отправки", $settings_menu)
	Global $send_hotkey_enter_item = GUICtrlCreateMenuItem("Enter", $send_hotkey_menu, -1, 1)
	If $send_hotkey_opt = 1 Then GUICtrlSetState($send_hotkey_enter_item, $GUI_CHECKED)
	Global $send_hotkey_ctrl_enter_item = GUICtrlCreateMenuItem("Ctrl+Enter", $send_hotkey_menu, -1, 1)
	If $send_hotkey_opt = 2 Then GUICtrlSetState($send_hotkey_ctrl_enter_item, $GUI_CHECKED)
	Global $opacity_menu = GUICtrlCreateMenu("Непрозрачность", $settings_menu)
	Global $trans_10_item = GUICtrlCreateMenuItem("10%", $opacity_menu, -1, 1)
	Global $trans_20_item = GUICtrlCreateMenuItem("20%", $opacity_menu, -1, 1)
	Global $trans_30_item = GUICtrlCreateMenuItem("30%", $opacity_menu, -1, 1)
	Global $trans_40_item = GUICtrlCreateMenuItem("40%", $opacity_menu, -1, 1)
	Global $trans_50_item = GUICtrlCreateMenuItem("50%", $opacity_menu, -1, 1)
	Global $trans_60_item = GUICtrlCreateMenuItem("60%", $opacity_menu, -1, 1)
	Global $trans_70_item = GUICtrlCreateMenuItem("70%", $opacity_menu, -1, 1)
	Global $trans_80_item = GUICtrlCreateMenuItem("80%", $opacity_menu, -1, 1)
	Global $trans_90_item = GUICtrlCreateMenuItem("90%", $opacity_menu, -1, 1)
	GUICtrlCreateMenuItem("", $opacity_menu)
	Global $trans_off_item = GUICtrlCreateMenuItem("Непрозрачное", $opacity_menu, -1, 1)
	GUICtrlCreateMenuItem("", $settings_menu)
	Global $font_item = GUICtrlCreateMenuItem("Шрифт...", $settings_menu)
	Global $help_menu = GUICtrlCreateMenu("Помощь")
	Global $homepage_item = GUICtrlCreateMenuItem("Сайт программы", $help_menu)
	Global $server_info_item = GUICtrlCreateMenuItem("Сведения о сервере", $help_menu)
	Global $about_item = GUICtrlCreateMenuItem("О программе", $help_menu)
	
	;Userlist Control
	Global $userlist_lv = GUICtrlCreateListView("", 488, 10, 170, 325, $LVS_NOCOLUMNHEADER + $LVS_SORTASCENDING + $LVS_SINGLESEL)
	_GUICtrlListView_SetExtendedListViewStyle($userlist_lv, $LVS_EX_FULLROWSELECT + $LVS_EX_INFOTIP)
	_GUICtrlListView_InsertColumn($userlist_lv, 0, "Список пользователей", 166)
	_RemoveWindowTheme(-1)
	
    Global $hToodfgmageList = _GUIImageList_Create(16, 16, 5, 3)
    _GUIImageList_AddIcon($hToodfgmageList, @ScriptDir &"\ico\user_mature.ico")
    _GUICtrlListView_SetImageList($userlist_lv, $hToodfgmageList, 1)

	Global $userlist_menu = GUICtrlCreateContextMenu($userlist_lv)
	Global $pm_item = GUICtrlCreateMenuItem("Отправить личное сообщение", $userlist_menu)
	Global $ac_item = GUICtrlCreateMenuItem("Разбудить", $userlist_menu)
	Global $file_send_item = GUICtrlCreateMenuItem("Передать файл", $userlist_menu)
	GUICtrlCreateMenuItem("", $userlist_menu)
	Global $copy_userlist_item = GUICtrlCreateMenuItem("Скопировать", $userlist_menu)
	Global $refresh_userlist_item = GUICtrlCreateMenuItem("Обновить список", $userlist_menu)

	;Tray Menu
	Global $show_tray_item = TrayCreateItem("Открыть")
	Global $exit_tray_item = TrayCreateItem("Выйти")

	Local $staus_parts[4] = [140, 310, 440, 650]
	Global $main_status = _GUICtrlStatusBar_Create($main_dlg)
	_GUICtrlStatusBar_SetParts($main_status, $staus_parts)

	_GUICtrlStatusBar_SetText($main_status, "Всего в чате: 0 / "& $max_clients, 0)
	_GUICtrlStatusBar_SetText($main_status, "Пользователь: "& $sNik, 1)
	_GUICtrlStatusBar_SetText($main_status, "Сервер: "& $server_ip, 2)
	_GUICtrlStatusBar_SetText($main_status, "Имя сервера: "& $server_name, 3)

	AdlibRegister("_UnCheckTray", 500)
	GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")
	GUISetState(@SW_SHOW)

	While 1
		Local $gMsg = GUIGetMsg(), $tMsg = TrayGetMsg()
		Select
			Case $gMsg = $exit_item or $tMsg = $exit_tray_item or $gMsg = $GUI_EVENT_CLOSE
				TcpCloseSocket($server)
				TCPShutdown()
				GuiDelete($main_dlg)
				Exit
			Case $gMsg = $exit_from_chat_item
				If MsgBox(4 + 32, "Внимание", "Вый действительно хотите выйти из чата?", -1, $main_dlg) = 6 Then
					TcpCloseSocket($server)
					GuiDelete($main_dlg)
					ExitLoop
				EndIf
			Case $gMsg = $GUI_EVENT_MINIMIZE
				_ChangeWindowState()
			Case $tMsg = $TRAY_EVENT_PRIMARYDOUBLE or $tMsg = $show_tray_item
				_ChangeWindowState()
			Case $gMsg = $homepage_item
				ShellExecute($homepage)
			Case $gMsg = $about_item
				MsgBox(64, "О программе", $application &" "& $version &@CRLF& "Copyright © 2010 [Nuker-Hoax]" &@CRLF&@CRLF& "Благодарности:" &@CRLF& "John2010zz" &@CRLF&@CRLF& $homepage, -1, $main_dlg)
			Case $gMsg = $server_info_item
				MsgBox(64, "Сведения о сервере", "Имя сервера:" &@CRLF& $server_name &@CRLF&@CRLF& "Адрес сервера:" &@CRLF& $server_ip &@CRLF&@CRLF& "Максимум пользователей:" &@CRLF& $max_clients &@CRLF&@CRLF& "Ваш ник:" &@CRLF& $sNik, -1, $main_dlg)
			Case $gMsg = $convert_text_btn
				Local $sTranslit = GUICtrlRead($send_edit)
				If $sTranslit <> "" Then GuiCtrlSetData($send_edit, _ConvertKeyboard($sTranslit))
			Case $gMsg = $save_item
				Local $sFile = FileSaveDialog("Выберите файл для сохранения...", "", "Текстовые файлы (*.txt)", 16, $sNik &"_log",$main_dlg)
				If not @error Then
					Local $hFile = FileOpen($sFile &".txt", 2)
					FileWrite($hFile, GUICtrlRead($history_edit))
					FileClose($hFile)
				EndIf
			Case $gMsg = $clear_item
				If MsgBox(4 + 32 + 262144, "Внимание", "Вы действительно хотите очистить историю?", -1, $main_dlg) = 6 Then GUICtrlSetData($history_edit, "")
			Case $gMsg = $ontop_item
				If $ontop_opt = 1 Then
					IniWrite($settings_file, "Client", "AlwaysOnTop", 0)
					GUICtrlSetState($ontop_item, $GUI_UNCHECKED)
				Else
					IniWrite($settings_file, "Client", "AlwaysOnTop", 1)
					GUICtrlSetState($ontop_item, $GUI_CHECKED)
				EndIf
				
				_ReadSettings()
			Case $gMsg = $usesnd_item
				If $usesnd_opt = 1 Then
					IniWrite($settings_file, "Client", "UseSound", 0)
					GUICtrlSetState($usesnd_item, $GUI_UNCHECKED)
				Else
					IniWrite($settings_file, "Client", "UseSound", 1)
					GUICtrlSetState($usesnd_item, $GUI_CHECKED)
				EndIf
				
				_ReadSettings()
			Case $gMsg = $send_hotkey_enter_item
				IniWrite($settings_file, "Client", "SendHotKey", 1)
				GUICtrlSetState($send_hotkey_enter_item, $GUI_CHECKED)
				
				_ReadSettings()
			Case $gMsg = $send_hotkey_ctrl_enter_item
				IniWrite($settings_file, "Client", "SendHotKey", 2)
				GUICtrlSetState($send_hotkey_ctrl_enter_item, $GUI_CHECKED)
				
				_ReadSettings()
			Case $gMsg = $font_item
				Local $font_name = _ChooseFont($font_name_opt, $font_size_opt, -1, -1, -1, -1, -1, $main_dlg)
				If $font_name <> -1 Then
					IniWrite($settings_file, "Client", "FontFace", $font_name[2])
					IniWrite($settings_file, "Client", "FontSize", $font_name[3])
					
					_ReadSettings()
				EndIf
			Case $gMsg = $file_send_item
				Local $selected = _GUICtrlListView_GetSelectedIndices($userlist_lv, 1)
				If $selected[0] <> 0 Then
					Local $together = _GUICtrlListView_GetItemTextArray($userlist_lv, $selected[1])
					If $together[0] <> 0 Then 
						Local $file_to_send = FileOpenDialog("Выберите файл для передачи...", "", "Все файлы (*.*)", 1 + 2, "", $main_dlg)
						If not @error Then
							Local $hTransferFile = FileOpen($file_to_send, 16)
							If not @error Then
								Local $sTransferFileName = StringRegExpReplace($file_to_send, '^.*\\', '')
								Local $sBuffer = Binary(FileRead($hTransferFile))
								FileClose($hTransferFile)
								
								While BinaryLen($sBuffer)
									Local $SendReturn = TCPSend($server, _EncodeText('<user="'& _ConvertStringToBinary($together[1]) &'" filename="'& _ConvertStringToBinary($sTransferFileName) &'" transferdata="'& _ConvertStringToBinary($sBuffer) &'" action="'& _ConvertStringToBinary("filetransfer") &'">'))
									$sBuffer = BinaryMid($sBuffer, $SendReturn + 1, BinaryLen($sBuffer) - $SendReturn)
									
									Sleep(100)
								WEnd
							EndIf
						EndIf
					EndIf
				EndIf
			Case $gMsg = $pm_item
				Local $selected = _GUICtrlListView_GetSelectedIndices($userlist_lv, 1)
				If $selected[0] <> 0 Then
					Local $together = _GUICtrlListView_GetItemTextArray($userlist_lv, $selected[1])
					If $together[0] <> 0 Then
						If GuiCtrlRead($send_edit) = "" Then
							MsgBox(16 + 262144, "Ошибка", "Текст сообщения необходимо ввести в поле отправки", -1, $main_dlg)
						Else
							TcpSend($server, _EncodeText('<user="'& _ConvertStringToBinary($together[1]) &'" message="'& _ConvertStringToBinary(GuiCtrlRead($send_edit)) &'" action="'& _ConvertStringToBinary("pm") &'">'))
							GUICtrlSetData($send_edit, "")
						EndIf
					EndIf
				EndIf
			Case $gMsg = $ac_item
				Local $selected = _GUICtrlListView_GetSelectedIndices($userlist_lv, 1)
				If $selected[0] <> 0 Then
					Local $together = _GUICtrlListView_GetItemTextArray($userlist_lv, $selected[1])
					If $together[0] <> 0 Then TcpSend($server, _EncodeText('<user="'& _ConvertStringToBinary($together[1]) &'" action="'& _ConvertStringToBinary("awake") &'">'))
				EndIf
			Case $gMsg = $send_btn
				Local $sRead = GUICtrlRead($send_edit)
				If $sRead <> "" Then
					$sRead = StringReplace($sRead, @CRLF, " ")
					$sRead = StringReplace($sRead, @CR, " ")
					$sRead = StringReplace($sRead, @LF, " ")
					If not StringIsSpace($sRead) Then
						TcpSend($server, _EncodeText('<message="'& _ConvertStringToBinary($sRead) &'" soundstate="'& _ConvertStringToBinary("1") &'" action="'& _ConvertStringToBinary("sendmessage") &'">'))
						If $usesnd_opt = 1 Then _WinAPI_PlaySound($send_snd)
						GUICtrlSetData($send_edit, "")
						GuiCtrlSetState($send_btn, $GUI_DISABLE)
						GuiCtrlSetState($convert_text_btn, $GUI_DISABLE)
					EndIf
				EndIf
			Case $gMsg = $copy_userlist_item
				Local $selected = _GUICtrlListView_GetSelectedIndices($userlist_lv, 1)
				If $selected[0] <> 0 Then
					Local $together = _GUICtrlListView_GetItemTextString($userlist_lv, $selected[1])
					If $together <> "" Then ClipPut($together)
				EndIf
			Case $gMsg = $refresh_userlist_item
				TcpSend($server, _EncodeText('<action="'& _ConvertStringToBinary("requestuserlist") &'">'))
			Case $gMsg = $trans_10_item
				GUICtrlSetState($trans_10_item, $GUI_CHECKED)
				_SetOpacity(10)			
			Case $gMsg = $trans_20_item
				GUICtrlSetState($trans_20_item, $GUI_CHECKED)
				_SetOpacity(20)
			Case $gMsg = $trans_30_item
				GUICtrlSetState($trans_30_item, $GUI_CHECKED)
				_SetOpacity(30)
			Case $gMsg = $trans_40_item
				GUICtrlSetState($trans_40_item, $GUI_CHECKED)
				_SetOpacity(40)
			Case $gMsg = $trans_50_item
				GUICtrlSetState($trans_50_item, $GUI_CHECKED)
				_SetOpacity(50)
			Case $gMsg = $trans_60_item
				GUICtrlSetState($trans_60_item, $GUI_CHECKED)
				_SetOpacity(60)
			Case $gMsg = $trans_70_item
				GUICtrlSetState($trans_70_item, $GUI_CHECKED)
				_SetOpacity(70)
			Case $gMsg = $trans_80_item
				GUICtrlSetState($trans_80_item, $GUI_CHECKED)
				_SetOpacity(80)
			Case $gMsg = $trans_90_item
				GUICtrlSetState($trans_90_item, $GUI_CHECKED)
				_SetOpacity(90)
			Case $gMsg = $trans_off_item
				
				_SetOpacity(100)
			Case $gMsg = $GUI_EVENT_PRIMARYDOWN
				_SendMessage($main_dlg, $WM_SYSCOMMAND, BitOR($SC_MOVE, $HTCAPTION), 0)
		EndSelect
			
		If $server <> -1 Then
			$tcpRecv_enc = TcpRecv($server, 1000000)
			
			If @error Then
				TcpCloseSocket($server)
				GUIDelete($main_dlg)
				ExitLoop
			EndIf
			
			$tcpRecv = _DecodeText($tcpRecv_enc)
			
			Local $action_expand = _GetValueFromString($tcpRecv, "action")

			Switch $action_expand
				Case "serverterminate"
					TcpCloseSocket($server)
					GUIDelete($main_dlg)
					ExitLoop
				Case "authorization"
					If _GetValueFromString($tcpRecv, "response") = "server_overflow" Then
						TcpCloseSocket($server)
						MsgBox(16 + 262144, "Ошибка", "Сервер переполнен", -1, $main_dlg)
						GUIDelete($main_dlg)
						ExitLoop
					EndIf
				Case "requestuserlist"
					Local $sUserData = _GetValueFromString($tcpRecv, "userlist", 0)
					Local $sUserList = StringSplit($sUserData, "|")

					_GUICtrlListView_DeleteAllItems(GUICtrlGetHandle($userlist_lv))
											
					For $i = 1 to $sUserList[0]
						If _ConvertBinaryToString($sUserList[$i]) <> $sNik Then _GUICtrlListView_AddItem($userlist_lv, _ConvertBinaryToString($sUserList[$i]), 0)
					Next
										
					_GUICtrlStatusBar_SetText($main_status, "Всего в чате: "& $sUserList[0] &" / "& $max_clients, 0)
				Case "kick"	
					TcpCloseSocket($server)
					MsgBox(16 + 262144, "Внимание", "Вы были выкинуты с сервера", 10, $main_dlg)
					GUIDelete($main_dlg)
					ExitLoop
				Case "pm"	
					Local $sPMText = _GetValueFromString($tcpRecv, "message")
					Local $sPMFrom = _GetValueFromString($tcpRecv, "from")
					Local $sPMTo = _GetValueFromString($tcpRecv, "to")
					Local $sPMDate = _GetValueFromString($tcpRecv, "date")

					_WriteHistory("["& $sPMDate &"] " & $sPMFrom &" > "& $sPMTo &" [PM]: "& $sPMText)
				Case "filetransfer"
					Local $sTransferUser = _GetValueFromString($tcpRecv, "user")
					Local $sTransferFile = _GetValueFromString($tcpRecv, "filename")
					Local $sTransferData = _GetValueFromString($tcpRecv, "transferdata")
					
					Local $hFile = FileOpen($files_dir &"\"& $sTransferFile, 1 + 8 + 16)
					
					FileWrite($hFile, $sTransferData)
					FileClose($hFile)
					
					_WriteHistory('['& @HOUR & ':' & @MIN &'] Принят файл "'& $sTransferFile &'" от "'& $sTransferUser &'"')
				Case "chatlog"
					Local $sChatLog = _GetValueFromString($tcpRecv, "log")

					$sChatLog = StringTrimRight($sChatLog, 1)
					_WriteHistory($sChatLog)
				Case "awake"
					Local $sAwakeUser = _GetValueFromString($tcpRecv, "user")
					If $usesnd_opt = 1 Then _WinAPI_PlaySound($alarm_snd)
					_ShakeWindow($main_dlg)
					_WriteHistory('['& @HOUR & ':' & @MIN &'] Пользователь "'& $sAwakeUser &'" попытался вас разбудить')
				Case "sendmessage"
					Local $sDate = _GetValueFromString($tcpRecv, "date")
					Local $sUserName = _GetValueFromString($tcpRecv, "username")
					Local $sMessage = _GetValueFromString($tcpRecv, "message")
					Local $sSound = _GetValueFromString($tcpRecv, "soundstate")
					If $sMessage <> "" Then _WriteHistory("["& $sDate &"] "& $sUserName &": "& $sMessage)
					If $sSound = 1 and $usesnd_opt = 1 and $sUserName <> $sNik Then _WinAPI_PlaySound($recieve_snd)
			EndSwitch
		EndIf
	WEnd
	
	TrayItemDelete($show_tray_item)
	TrayItemDelete($exit_tray_item)
	TraySetState(2)
	
	_ActionDlg(1)
EndFunc

Func _ChangeWindowState()
	Local $iState = WinGetState($main_dlg)

	If BitAnd($iState, 2) Then
		GUISetState(@SW_HIDE, $main_dlg)
	Else
		GUISetState(@SW_SHOW, $main_dlg)
	EndIf
EndFunc

Func _ReadSettings()
	Global $opacity_opt = (255 / 100) * IniRead($settings_file, "Client", "Opacity", 100)
	WinSetTrans($main_dlg, "", $opacity_opt)
	
	Global $usesnd_opt = IniRead($settings_file, "Client", "UseSound", 1)
	Global $ontop_opt = IniRead($settings_file, "Client", "AlwaysOnTop", 1)
	
	If $ontop_opt = 1 Then 
		WinSetOnTop($main_dlg, "", 1)
	Else
		WinSetOnTop($main_dlg, "", 0)
	EndIf
	
	Global $font_name_opt = IniRead($settings_file, "Client", "FontFace", "Arial")
	Global $font_size_opt = IniRead($settings_file, "Client", "FontSize", "8.5")
	
	GUICtrlSetFont($history_edit, $font_size_opt, -1, -1, $font_name_opt)
	GUICtrlSetFont($send_edit, $font_size_opt, -1, -1, $font_name_opt)
	
	Global $send_hotkey_opt = IniRead($settings_file, "Client", "SendHotKey", "1")
	
	If $send_hotkey_opt = 1 Then
		Dim $HK[1][2]=[["{ENTER}", $send_btn]]
	ElseIf $send_hotkey_opt = 2 Then
		Dim $HK[1][2]=[["^{ENTER}", $send_btn]]
	EndIf
	
	GUISetAccelerators($HK)
EndFunc

Func _SetOpacity($iPercent)
	IniWrite($settings_file, "Client", "Opacity", $iPercent)
	
	_ReadSettings()
EndFunc

Func _WriteHistory($sText)
	GUICtrlSetData($history_edit, GUICtrlRead($history_edit) & $sText & @CRLF)
	_GUICtrlEdit_LineScroll($history_edit, 0, _GUICtrlEdit_GetLineCount($history_edit) - 1)
EndFunc

Func _ServerProcessor()
	_CreateMutex("LEET_SERVER")
	
	;Configure Tray menu
	TraySetState(1)
	;Opt("TrayOnEventMode", 1)
	TraySetIcon(@ScriptFullPath, 101)

	;Server Settings
	Global $max_users = $max_clients, $socket[$max_users + 1], $username[$max_users + 1], $userdate[$max_users + 1], $userclient[$max_users + 1]

	For $i = 1 to $max_users
		$socket[$i] = -1
		$username[$i] = -1
		$userdate[$i] = -1
		$userclient[$i] = -1
	Next

	Global $manage_dlg = GUICreate("Управление сервером", 461, 599)
	GUISetIcon(@ScriptFullPath, -2)

	Global $file_menu = GUICtrlCreateMenu("Файл")
	Global $save_history_item = GUICtrlCreateMenuItem("Сохранить историю", $file_menu)
	Global $clear_history_item = GUICtrlCreateMenuItem("Очистить историю", $file_menu)
	GUICtrlCreateMenuItem("", $file_menu)
	Global $exit_item = GUICtrlCreateMenuItem("Выйти", $file_menu)

	Global $help_menu = GUICtrlCreateMenu("Помощь")
	GUICtrlCreateMenuItem("Сайт программы", $help_menu)
	GUICtrlCreateMenuItem("О программе", $help_menu)

	Global $userlist_lv = GUICtrlCreateListView("", 10, 10, 441, 200, $LVS_SINGLESEL + $LVS_SORTASCENDING + $LVS_NOSORTHEADER)
	_GUICtrlListView_SetExtendedListViewStyle($userlist_lv, $LVS_EX_GRIDLINES + $LVS_EX_FULLROWSELECT + $LVS_EX_INFOTIP)

	_GUICtrlListView_InsertColumn($userlist_lv, 0, "Пользователь", 100)
	_GUICtrlListView_InsertColumn($userlist_lv, 1, "Адрес пользователя", 120)
	_GUICtrlListView_InsertColumn($userlist_lv, 2, "Версия клиента", 100)
	_GUICtrlListView_InsertColumn($userlist_lv, 3, "Дата подключения", 120)

	Global $userlist_menu = GUICtrlCreateContextMenu($userlist_lv)
	Global $kick_item = GUICtrlCreateMenuItem("Выкинуть", $userlist_menu)
	Global $copy_item = GUICtrlCreateMenuItem("Копировать", $userlist_menu)

	Global $history_edit = GUICtrlCreateEdit("", 10, 220, 441, 200, $ES_MULTILINE + $ES_READONLY + $ES_AUTOVSCROLL, $WS_EX_STATICEDGE)
	Global $send_input = GUICtrlCreateInput("", 10, 428, 410, 21, -1, $WS_EX_STATICEDGE)
	Global $send_btn = GUICtrlCreateButton("", 427, 428, 24, 21, $BS_ICON)
	GUICtrlSetImage(-1, @ScriptDir &"\ico\pencil_go.ico")

	GUICtrlCreateLabel("", 10, 458, 441, 89, -1, $WS_EX_STATICEDGE)

	_GUICtrlStatusBar_Create($manage_dlg)

	$connected_old = $connected
	$server_log_old = $server_log
	
	AdlibRegister("_RefreshStatistics", 500)
	
	GUISetState(@SW_HIDE)

	Global $show_tray_item = TrayCreateItem("Показать")
	Global $copy_tray_item = TrayCreateItem("Скопировать адрес сервера")
	TrayCreateItem("")
	Global $exit_tray_item = TrayCreateItem("Выйти")

	AdlibRegister("_UnCheckTray", 500)
	AdlibRegister("_SendStats", 60000)
	
	While 1
		Local $gMsg = GUIGetMsg(), $tMsg = TrayGetMsg()
		Select
			Case $gMsg = $exit_item or $tMsg = $exit_tray_item
				If MsgBox(4 + 32 + 262144, "Внимание", "Вы действительно хотите завершить работу сервера?", -1, $manage_dlg) = 6 Then
					GuiDelete($manage_dlg)
					
					If $connected > 0 Then
						_SendAll("Сервер", "Сервер завершает свою работу")
						
						Sleep(1500)
						
						_SendAll("", "", "serverterminate")
					EndIf
					
					TcpCloseSocket($server)
					TCPShutdown()
					Exit
				EndIf
			Case $gMsg = $GUI_EVENT_CLOSE or $tMsg = $show_tray_item or $tMsg = $TRAY_EVENT_PRIMARYDOUBLE
				Local $iState = WinGetState($manage_dlg)

				If BitAnd($iState, 2) Then
					GUISetState(@SW_HIDE, $manage_dlg)
				Else
					GUISetState(@SW_SHOW, $manage_dlg)
				EndIf
			Case $gMsg = $GUI_EVENT_PRIMARYDOWN
				_SendMessage($manage_dlg, $WM_SYSCOMMAND, BitOR($SC_MOVE, $HTCAPTION), 0)
			Case $gMsg = $save_history_item
				If $server_log <> "" Then
					Local $log_file = FileSaveDialog("Выберите файл для сохранения отчёта...", "", "Текстовые файлы (*.txt)", 16, "leet_server_log.txt", $manage_dlg)
					If not @error Then
						Local $hFile = FileOpen($log_file, 2)
						FileWrite($hFile, $server_log)
						FileClose($hFile)
					EndIf
				EndIf
			Case $gMsg = $clear_history_item
				If MsgBox(4 + 32 + 262144, "Внимание", "Вы действительно хотите очистить отчёт?", -1, $manage_dlg) = 6 Then
					$server_log = ""
					GUICtrlSetData($history_edit, $server_log)
				EndIf
			Case $gMsg = $kick_item
				Local $sKickSocket = -1
				Local $selected = _GUICtrlListView_GetSelectedIndices($userlist_lv, True)
				If $selected[0] <> 0 Then
					Local $together = _GUICtrlListView_GetItemTextArray($userlist_lv, $selected[1])
					If $together[0] <> 0 Then
						If MsgBox(4 + 32 + 262144, "Внимание", 'Вы действительно хотите выкинуть пользователя "'& $together[1] &'" с сервера?', -1, $manage_dlg) = 6 Then
							
							For $i = 1 to $max_users
								If $username[$i] = $together[1] Then $sKickSocket = $socket[$i]
							Next

							TCPSend($sKickSocket, _EncodeText('<action="kick">'))
							TCPCloseSocket($sKickSocket)
						EndIf
					EndIf
				EndIf
			Case $gMsg = $copy_item
				Local $selected = _GUICtrlListView_GetSelectedIndices($userlist_lv, True)
				If $selected[0] <> 0 Then
					Local $together = _GUICtrlListView_GetItemTextString($userlist_lv, $selected[1])
					If $together <> "" Then ClipPut($together)
				EndIf
			Case $gMsg = $send_btn
				Local $send_data = GUICtrlRead($send_input)
				If $send_data <> "" and not StringIsSpace($send_data) Then 
					_SendAll("Сервер", $send_data, "sendmessage", 0, 1)
					GUICtrlSetData($send_input, "")
					_RefreshStatistics()
				EndIf
			Case $tMsg = $copy_tray_item
				ClipPut($server_ip)
		EndSelect

		If $server <> -1 Then
			If $connected < $max_users Then
				$tcp_accept = TcpAccept($server)

				If $tcp_accept <> -1 Then
					$open = _Open()
					$timer = TimerInit()

					Do
						Sleep(15)
						$tcp_recv_enc = TcpRecv($tcp_accept, 1000000)
						$tcp_recv = _DecodeText($tcp_recv_enc)
					Until $tcp_recv <> "" or TimerDiff($timer) >= 500
						
					If $tcp_recv <> "" Then
						Local $action_expand = _GetValueFromString($tcp_recv, "action")
						
						If $action_expand = "authorization" Then
							Local $username_expand = _GetValueFromString($tcp_recv, "username")
							Local $password_expand = _GetValueFromString($tcp_recv, "password")
							Local $client_expand = _GetValueFromString($tcp_recv, "client")
							
							If _UsernameExists($username_expand) = 1 Then
								If $server_pswd <> $password_expand Then
									TcpSend($tcp_accept, _EncodeText('<response="'& _ConvertStringToBinary("invalid_password") &'" action="'& _ConvertStringToBinary("authorization") &'">'))
									TcpCloseSocket($tcp_accept)
								Else
									$username[$open] = $username_expand
									$socket[$open] = $tcp_accept
									$userdate[$open] = @MDAY &"-"& @MON &"-"& @YEAR &" ("& @HOUR &":"& @MIN &":"& @SEC &")"
									$userclient[$open] = $client_expand
									$connected += 1
									
									TcpSend($tcp_accept, _EncodeText('<response="'& _ConvertStringToBinary("connection_accepted") &'" max_clients="'& _ConvertStringToBinary($max_users) &'" server_name="'& _ConvertStringToBinary($server_name) &'" action="'& _ConvertStringToBinary("authorization") &'">'))
									
									Sleep(50)

									If $chat_log <> "" Then TcpSend($tcp_accept, _EncodeText('<log="'& _ConvertStringToBinary($chat_log) &'" action="'& _ConvertStringToBinary("chatlog") &'">'))
									
									Sleep(50)
									
									_SendAll("Сервер", $username[$open] &" присоединился")
									
									_SendStats()
								EndIf
							Else
								TcpSend($tcp_accept, _EncodeText('<response="'& _ConvertStringToBinary("username_already_exists") &'" action="'& _ConvertStringToBinary("authorization") &'">'))
								TcpCloseSocket($tcp_accept)
							EndIf
						EndIf
					EndIf
				EndIf
			Else
				TcpSend($tcp_accept, _EncodeText('<response="'& _ConvertStringToBinary("server_overflow") &'" action="'& _ConvertStringToBinary("authorization") &'">'))
				Sleep(15)
				TcpCloseSocket($tcp_accept)
			EndIf
			
			For $i = 1 to $max_users
				If $socket[$i] <> -1 and $username[$i] <> -1 Then
					$tcp_recv_enc = TcpRecv($socket[$i], 1000000)
					If @error Then _DisconnectUser($i)
					$tcp_recv = _DecodeText($tcp_recv_enc)
					
					Local $action_expand = _GetValueFromString($tcp_recv, "action")

					Switch $action_expand
						Case "requestuserlist"
							TCPSend($socket[$i], _EncodeText(_GetStats()))
						Case "awake"
							Local $sUserAwake = _GetValueFromString($tcp_recv, "user"), $sTransferSocket = -1

							For $a = 1 to $max_users
								If $username[$a] = $sUserAwake Then $sTransferSocket = $socket[$a]
							Next
							
							TCPSend($sTransferSocket, _EncodeText('<user="'& $username[$i] &'" action="awake">'))
						Case "pm"
							Local $sPMUser = _GetValueFromString($tcp_recv, "user"), $sPMData = _GetValueFromString($tcp_recv, "message"), $sTransferSocket = -1

							For $a = 1 to $max_users
								If $username[$a] = $sPMUser Then $sTransferSocket = $socket[$a]
							Next
							
							If $sTransferSocket <> -1 Then
								Local $pm_text = "["& @HOUR &":"& @MIN &"] " & $username[$i] &" > "& $sPMUser &" [PM]: "& $sPMData, $sDate = @HOUR &":"& @MIN
								
								$server_log &= $pm_text &@CRLF
				
								TCPSend($sTransferSocket, _EncodeText('<message="'& _ConvertStringToBinary($sPMData) &'" date="'& _ConvertStringToBinary($sDate) &'" from="'& _ConvertStringToBinary($username[$i]) &'" to="'& _ConvertStringToBinary($sPMUser) &'" action="'& _ConvertStringToBinary("pm") &'">'))
								TCPSend($socket[$i], _EncodeText('<message="'& _ConvertStringToBinary($sPMData) &'" date="'& _ConvertStringToBinary($sDate) &'" from="'& _ConvertStringToBinary($username[$i]) &'" to="'& _ConvertStringToBinary($sPMUser) &'" action="'& _ConvertStringToBinary("pm") &'">'))
							EndIf
						Case "filetransfer"
							Local $sTransferData = _GetValueFromString($tcp_recv, "transferdata"), $sTransferFileName = _GetValueFromString($tcp_recv, "filename"), $sTransferUser = _GetValueFromString($tcp_recv, "user"), $sTransferSocket = -1
							
							For $a = 1 to $max_users
								If $username[$a] = $sTransferUser Then $sTransferSocket = $socket[$a]
							Next
							
							TCPSend($sTransferSocket, _EncodeText('<user="'& _ConvertStringToBinary($username[$i]) &'" filename="'& _ConvertStringToBinary($sTransferFileName) &'" transferdata="'& _ConvertStringToBinary($sTransferData) &'" action="'& _ConvertStringToBinary("filetransfer") &'">'))
						Case "sendmessage"
							Local $sMessage = _GetValueFromString($tcp_recv, "message")
							_SendAll($username[$i], $sMessage, "sendmessage", 0, 1)
					EndSwitch
				EndIf
			Next
		EndIf
	WEnd
EndFunc

Func _RefreshStatistics()
	;Chat Log
	If $server_log_old <> $server_log Then
		GUICtrlSetData($history_edit, $server_log)
		_GUICtrlEdit_LineScroll($history_edit, 0, _GUICtrlEdit_GetLineCount($history_edit) - 1)
		
		$server_log_old = $server_log
	EndIf
	
	;User List
	If $connected_old <> $connected Then
		_GUICtrlListView_DeleteAllItems(GUICtrlGetHandle($userlist_lv))
		
		For $i = 1 to $max_users
			If $username[$i] <> -1 Then 
				Local $iItem = _GUICtrlListView_AddItem($userlist_lv, $username[$i])
				_GUICtrlListView_AddSubItem($userlist_lv, $iItem, _SocketGetIP($socket[$i]), 1)
				_GUICtrlListView_AddSubItem($userlist_lv, $iItem, $userclient[$i], 2)
				_GUICtrlListView_AddSubItem($userlist_lv, $iItem, $userdate[$i], 3)
			EndIf
		Next
		
		$connected_old = $connected
	EndIf
	
	TraySetToolTip($application &" "& $version &@CRLF&@CRLF& "Имя сервера: "& $server_name &@CRLF& "Адрес сервера: "& $server_ip &@CRLF& "Всего в чате: "& $connected &" / "& $max_users)
EndFunc

Func _GetStats()
	Local $sStats
	
	For $i = 1 to $max_users
		If $username[$i] <> -1 Then $sStats &= _ConvertStringToBinary($username[$i]) &"|"
	Next

	If StringRight($sStats, 1) = "|" Then $sStats = StringTrimRight($sStats, 1)
		
	Return '<userlist="'& $sStats &'" action="'& _ConvertStringToBinary("requestuserlist") &'">'
EndFunc

Func _SendStats()
	For $i = 1 to $max_users
		If $socket[$i] <> -1 and $username[$i] <> -1 Then TcpSend($socket[$i], _EncodeText(_GetStats()))
	Next
EndFunc

Func _SendAll($sUserName, $sMessage, $sAction = "sendmessage", $iConspirate = 0, $iSound = 0)
	If $iConspirate = 1 Then Sleep(50)
	
	Local $sDate = @HOUR &":"& @MIN
	
	For $i = 1 to $max_users
		If $socket[$i] <> -1 and $username[$i] <> -1 Then
			TcpSend($socket[$i], _EncodeText('<message="'& _ConvertStringToBinary($sMessage) &'" date="'& _ConvertStringToBinary($sDate) &'" username="'& _ConvertStringToBinary($sUserName) &'" soundstate="'& _ConvertStringToBinary($iSound) &'" action="'& _ConvertStringToBinary($sAction) &'">'))
		EndIf
	Next
	
	If $iConspirate <> 1 Then 
		$chat_log &= "["& $sDate &"] "& $sUserName &": "& $sMessage &@CRLF
		$server_log &= "["& $sDate &"] "& $sUserName &": "& $sMessage &@CRLF
	EndIf
	
	If $iConspirate = 1 Then Sleep(50)
EndFunc

Func _UsernameExists($sData)
	For $i = 1 to $max_users
		If $username[$i] = $sData Then Return 0
	Next
		
	Return 1
EndFunc

Func _Open()
	For $i = 1 to $max_users
		If $socket[$i] = -1 and $username[$i] = -1 Then Return $i
	Next
EndFunc

Func _DisconnectUser($iID)
	_SendAll("Сервер", $username[$iID] &" вышел")
	
	TcpCloseSocket($socket[$iID])
	$socket[$iID] = -1
	$username[$iID] = -1
	$userdate[$iID] = -1
	$userclient[$iID] = -1
	$connected -= 1
	
	_SendStats()
EndFunc

Func _SocketGetIP($sSocket)
	Local $Struct, $Return
	$Struct = DllStructCreate ('short;ushort;uint;char[8]')
    $Return = DllCall('Ws2_32.dll','int','getpeername','int', $sSocket, 'ptr', DllStructGetPtr ($Struct), 'int*', DllStructGetSize($Struct))
	If @error Or $Return[0] <> 0 Then Return 0
	$Return = DllCall('Ws2_32.dll','str','inet_ntoa','int', DllStructGetData ($Struct, 3))
	If @error Then Return 0
	$Struct = 0
	Return $Return[0]
EndFunc

Func _UserGetSocket($sSocket)
	For $i = 1 to $max_users
		If $username[$i] = $sSocket Then Return $i
	Next
		
	Return -1
EndFunc

Func _UnCheckTray()
	;Client Menu
	If IsDeclared("show_tray_item") Then TrayItemSetState($show_tray_item, $TRAY_UNCHECKED)
	If IsDeclared("exit_tray_item") Then TrayItemSetState($exit_tray_item, $TRAY_UNCHECKED)
	
	;Server Menu
	If IsDeclared("show_tray_item") Then TrayItemSetState($show_tray_item, $TRAY_UNCHECKED)
	If IsDeclared("copy_tray_item") Then TrayItemSetState($copy_tray_item, $TRAY_UNCHECKED)
	If IsDeclared("exit_tray_item") Then TrayItemSetState($exit_tray_item, $TRAY_UNCHECKED)
EndFunc

Func _GetValueFromString($sString, $sValue, $iBinary = 1)
	Local $sReturn = "", $sPattern = '(?s).*'& $sValue &'="([^"]*)".*'
	Local $iCheck = StringRegExp($sString, $sPattern)
	
	If $iCheck = 1 Then $sReturn = StringRegExpReplace($sString, $sPattern, '\1')
	
	If $iBinary = 1 Then
		Return _ConvertBinaryToString($sReturn)
	Else
		Return $sReturn
	EndIf
EndFunc

Func _WinAPI_PlaySound($sFile)
	Local $ret = DllCall("winmm.dll", "int", "PlaySoundW", "wstr", $sFile, "ptr", 0, "dword", 0x0001 + 0x0002)
	If @error Then Return SetError(1, 0, 0)

	Return $ret[0]
EndFunc

Func _EncodeText($sText)
	If $sText = "" Then Return ""	
	Return RC4($sText, $cipher_key, 0)
EndFunc

Func _DecodeText($sText)
	If $sText = "" Then Return ""
	Return RC4($sText, $cipher_key, 1)
EndFunc

Func _ConvertStringToBinary($sText)
	If $sText = "" Then Return ""
	Return StringToBinary($sText)
EndFunc

Func _ConvertBinaryToString($sText)
	If $sText = "" Then Return ""
	Return BinaryToString($sText)
EndFunc

Func _nCrypt($sString, $bKey)
	Local $Cipher[256], $Keys[256], $Loop = 0, $Return = "", $Temp1 = 0, $Temp2 = 0, $Temp3 = 0
	$intLength = StringLen($bKey)
	For $Loop = 0 To 255
		$Keys[$Loop] = Asc(StringMid($bKey, (Mod($Loop, $intLength)) + 1, 1))
		$Cipher[$Loop] = $Loop
	Next
	For $Loop = 0 To 255
		$Temp1 = Mod($Temp1 + $Cipher[$Loop] + $Keys[$Loop], 256)
		$Cipher[$Loop] = $Cipher[$Temp1]
		$Cipher[$Temp1] = $Cipher[$Loop]
	Next
	For $Loop = 1 To StringLen($sString)
		$Temp2 = Mod(($Temp2 + 1), 256)
		$Temp3 = Mod(($Temp3 + $Cipher[$Temp2]), 256)
		$Return = $Return & Chr(BitXOR(Asc(StringMid($sString, $Loop, 1)), $Cipher[Mod(($Cipher[$Temp3] + $Cipher[$Temp2]), 256)]))
	Next
	Return $Return
EndFunc

Func _ConvertKeyboard($sString) 
    Local $sEnglish = 'q|w|e|r|t|y|u|i|o|p|[|]|a|s|d|f|g|h|j|k|l|;|"|z|x|c|v|b|n|m|,|.' 
    $sEnglish &= '|' & StringUpper($sEnglish) 
 
    Local $sRussian = 'й|ц|у|к|е|н|г|ш|щ|з|х|ъ|ф|ы|в|а|п|р|о|л|д|ж|э|я|ч|с|м|и|т|ь|б|ю' 
    $sRussian &= '|' & StringUpper($sRussian) 
 
    Local $aEnglish = StringSplit($sEnglish, "|") 
    Local $aRussian = StringSplit($sRussian, "|") 
 
    Local $sReturn = $sString 
 
    For $i = 1 To $aEnglish[0]
		Local $iEnglish = StringRegExp($sString, '[a-zA-Z]', 3), $iRussian = StringRegExp($sString, '[а-яА-Я]', 3)
			
		If UBound($iEnglish) > UBound($iRussian) Then
			$sReturn = StringReplace($sReturn, $aEnglish[$i], $aRussian[$i], 0, 1)
		Else
			$sReturn = StringReplace($sReturn, $aRussian[$i], $aEnglish[$i], 0, 1) 
		EndIf
    Next 
 
    Return $sReturn 
EndFunc

Func _ShakeWindow($hWnd, $iAmount = 10)
    Local $iPos = WinGetPos($hWnd)
	
    For $i = 0 to 20 step 1
		WinMove($hWnd,"", $iPos[0], $iPos[1] + $iAmount)
		Sleep(10)
		WinMove($hWnd,"", $iPos[0] + $iAmount, $iPos[1])
		Sleep(10)
		WinMove($hWnd,"", $iPos[0], $iPos[1] - $iAmount)
		Sleep(10)
		WinMove($hWnd,"", $iPos[0] - $iAmount , $iPos[1])
		Sleep(10)
		WinMove($hWnd,"", $iPos[0], $iPos[1])
		Sleep(10)
    Next
EndFunc

Func _RemoveWindowTheme($hWnd)
	Return
	DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle($hWnd), "wstr", "", "wstr", "")
EndFunc

Func _WindowFromPoint()
    Local $iRet = DllCall("user32.dll", "int", "WindowFromPoint", "long", MouseGetPos(0), "long", MouseGetPos(1))
    If IsArray($iRet) Then Return HWnd($iRet[0])
    Return SetError(1, 0, 0)
EndFunc

Func RC4($Data, $Phrase, $Decrypt)
   Local $a, $b, $i, $j, $k, $cipherby, $cipher
   Local $tempSwap, $temp, $PLen
   Local $sbox[256], $key[256]
   
   $PLen = StringLen($Phrase)
   For $a = 0 To 255
      $key[$a] = Asc(StringMid($Phrase, Mod($a, $PLen) + 1, 1))
      $sbox[$a] = $a
   Next
   
   $b = 0
   For $a = 0 To 255
      $b = Mod( ($b + $sbox[$a] + $key[$a]), 256)
      $tempSwap = $sbox[$a]
      $sbox[$a] = $sbox[$b]
      $sbox[$b] = $tempSwap
   Next
   
   If $Decrypt Then
      For $a = 1 To StringLen($Data) Step 2
         $i = Mod(($i + 1), 256)
         $j = Mod(($j + $sbox[$i]), 256)
         $k = $sbox[Mod(($sbox[$i] + $sbox[$j]), 256)]
         $cipherby = BitXOR(Dec(StringMid($Data, $a, 2)), $k)
         $cipher = $cipher & Chr($cipherby)
      Next
   Else
      For $a = 1 To StringLen($Data)
         $i = Mod(($i + 1), 256)
         $j = Mod(($j + $sbox[$i]), 256)
         $k = $sbox[Mod(($sbox[$i] + $sbox[$j]), 256)]
         $cipherby = BitXOR(Asc(StringMid($Data, $a, 1)), $k)
         $cipher = $cipher & Hex($cipherby, 2)
      Next
   EndIf
   Return $cipher
EndFunc  ;==>RC4

Func _OpenMutex($sMutex)
    Local $hMutex = DllCall("Kernel32.dll", "hwnd", "OpenMutex", "int", 0x1F0001, "int", 1, "str", $sMutex)
    Local $aGLE = DllCall("Kernel32.dll", "int", "GetLastError")
    If IsArray($aGLE) And $aGLE[0] = 127 Then Return 1
    Return 0
EndFunc 

Func _CreateMutex($sMutex)
    Local $handle, $lastError
    $handle = DllCall("kernel32.dll", "int", "CreateMutex", "int", 0, "long", 1, "str", $sMutex)
    $lastError = DllCall("kernel32.dll", "int", "GetLastError")
    Return $lastError[0] = 183
EndFunc

Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
    Switch BitAND($wParam, 0xFFFF)
        Case $send_edit
            Switch BitShift($wParam, 16)
				Case $EN_CHANGE
					If GUICtrlRead($send_edit) = "" Then
						GuiCtrlSetState($send_btn, $GUI_DISABLE)
						GuiCtrlSetState($convert_text_btn, $GUI_DISABLE)
					Else
						GuiCtrlSetState($send_btn, $GUI_ENABLE)
						GuiCtrlSetState($convert_text_btn, $GUI_ENABLE)
					EndIf
            EndSwitch
    EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc