# start.ps1
# ©w¸q®e¾¹©M¬M¹³ÀÉ¦WºÙ
$IMAGE_NAME = "youtube-dl-webui"
$CONTAINER_NAME = "youtube-dl-container"

# å®šç¾©å°ˆæ??®é?
$PROJECT_DIR = (Get-Item .).FullName

# ÀË¬d®e¾¹¬O§_¤w¸g¦s¦b¨Ã¹B¦æ¡A¦pªG¦³ªº¸Ü¡A¥ý°±¤î¨Ã²¾°£
$existingContainers = docker ps -a --filter "name=$CONTAINER_NAME" --format "{{.ID}}"
if ($existingContainers) {
    Write-Host "Stopping and removing existing container: $CONTAINER_NAME"
    docker stop $CONTAINER_NAME | Out-Null
    docker rm $CONTAINER_NAME | Out-Null
}

# «Ø¥ß Docker ¬M¹³ÀÉ
Write-Host "Building Docker image: $IMAGE_NAME"
docker build -t $IMAGE_NAME $PROJECT_DIR

# ÀË¬d¬M¹³ÀÉ¬O§_«Ø¥ß¦¨¥\
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Docker image build failed."
    exit 1
}

# è¨­å?ä¸‹è??®é???Windows è·¯å?
# è«‹å??™è£¡?„è·¯å¾‘ä¿®?¹ç‚ºä½ ç?å¯¦é? Windows ä¸‹è?è·¯å?
# ½ÐÀË¬d§Aªº start.ps1 ¸}¥»
# §ä¨ì docker run «ü¥Oªº³¡¤À¡A½T«O¥¦¬O³o¼Ë¼gªº¡G

# ³]©w¤U¸ü¥Ø¿ýªº Windows ¸ô®|
$DOWNLOAD_PATH = "D:\_TEMP"

# ±Ò°Ê·sªº®e¾¹
Write-Host "Starting new container: $CONTAINER_NAME"
docker run -d `
    --name $CONTAINER_NAME `
    -p 5000:5000 `
    --mount type=bind,source="$DOWNLOAD_PATH",target="/app/downloads" `
    --restart unless-stopped `
    $IMAGE_NAME