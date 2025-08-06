import os
import json
import subprocess
from flask import Flask, render_template, request, Response

# 設定 Flask 應用程式
app = Flask(__name__)

# 設定下載檔案的儲存目錄
# 在 Docker 容器內，下載目錄掛載到 /app/downloads
# 即使在 Windows 系統上，容器內部也使用 Linux 格式路徑
DOWNLOAD_DIR = '/app/downloads/'

# 檢查 yt-dlp 是否在 PATH 中，若否則使用完整路徑
def get_yt_dlp_path():
    path = subprocess.getoutput('which yt-dlp')
    if path and 'not found' not in path:
        return path
    # 如果 which 找不到，你可以手動指定一個可能的位置
    # 例如：
    # return '/usr/local/bin/yt-dlp'
    # 或者讓程式報錯，要求使用者手動安裝
    return 'yt-dlp'

YT_DLP_PATH = get_yt_dlp_path()

# 確保下載目錄存在，若不存在則建立
os.makedirs(DOWNLOAD_DIR, exist_ok=True)


@app.route('/')
def index():
    """首頁，顯示下載表單"""
    return render_template('index.html')


@app.route('/download', methods=['POST'])
def download():
    """處理表單提交，重導向到進度頁面"""
    url = request.form['url']
    download_format = request.form['format']
    custom_filename = request.form['filename']

    # 將參數傳遞給 progress.html
    return render_template(
        'progress.html', 
        url=url, 
        download_format=download_format, 
        custom_filename=custom_filename
    )


@app.route('/stream_progress')
def stream_progress():
    """使用 SSE 技術，以串流方式傳送下載進度"""
    url = request.args.get('url')
    download_format = request.args.get('download_format')
    custom_filename = request.args.get('custom_filename')

    def generate():
        try:
            yield f'data: {{"message": "yt-dlp 命令已啟動..."}}\n\n'
            
            # 建立 yt-dlp 命令列表
            cmd = [YT_DLP_PATH]

            # 設定輸出檔名與路徑
            if custom_filename:
                # 移除不安全的字元並設定檔名
                safe_filename = "".join(c for c in custom_filename if c.isalnum() or c in (' ', '_', '-')).rstrip()
                cmd.extend(['-o', os.path.join(DOWNLOAD_DIR, f'{safe_filename}.%(ext)s')])
            else:
                cmd.extend(['-o', os.path.join(DOWNLOAD_DIR, '%(title)s.%(ext)s')])
            
            # 設定下載格式
            if download_format == 'mp3':
                # 下載音訊並轉換為 mp3，需要 ffmpeg
                cmd.extend(['-x', '--audio-format', 'mp3'])
            else:
                # 下載影片，合併最佳影片與音訊
                cmd.extend(['-f', 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]'])

            # 加入影片連結
            cmd.append(url)

            # 使用 subprocess 執行 yt-dlp 並讀取輸出
            process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
            
            for line in iter(process.stdout.readline, ''):
                # 傳送每一行輸出給瀏覽器
                yield f'data: {{"message": {json.dumps(line.strip())}}}\n\n'

            process.wait()

            if process.returncode == 0:
                yield 'data: {"message": "下載成功！"}\n\n'
            else:
                yield f'data: {{"message": "下載失敗，錯誤代碼: {process.returncode}"}}\n\n'
        except Exception as e:
            # 處理例外狀況
            yield f'data: {{"message": "下載失敗，發生例外狀況: {str(e)}", "error": true}}\n\n'

    return Response(generate(), mimetype='text/event-stream')


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)