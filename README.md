# setting
修改 PowerShell 的執行原則，以允許腳本運行
以系統管理員身份執行以下步驟：
  開啟 PowerShell (以系統管理員身份)
  點擊 Windows 開始按鈕。
  輸入 PowerShell。

在「Windows PowerShell」或「PowerShell」的選項上按右鍵，選擇「以系統管理員身分執行」。
變更執行原則
在 PowerShell 視窗中，執行以下指令：

Set-ExecutionPolicy RemoteSigned

確認變更
系統會詢問你是否要變更執行原則。輸入 Y 然後按下 Enter 鍵來確認。


RemoteSigned 這個執行原則允許你執行本地創建的腳本，但會要求遠端下載的腳本需要有數位簽章。這是一個合理的折衷，既能讓你運行自己的腳本，又能防止惡意腳本的自動執行。

# run
cd C:\Users\peter\works\0805-youtube-download\
.\start.ps1

# @localhost
http://localhost:5000
