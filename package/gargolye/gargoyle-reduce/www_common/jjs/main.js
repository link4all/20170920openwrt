

function showLoading() {
    iPath.LodingMask();
}

function hideLoading() {
    iPath.UnLodingMask(); 
}

function setCurrentPath(txt) {
    $('.current').text('当前位置：' + txt);
}