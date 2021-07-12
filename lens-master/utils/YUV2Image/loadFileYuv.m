% function mov = loadFileYuv(fileName, width, height, idxFrame)

% function [mov,imgRgb,imgYuv] = loadFileYuv(fileName, width, height, idxFrame)
function [mov] = loadFileYuv(fileName, width, height, idxFrame)
% load RGB movie [0, 255] from YUV 4:2:0 file

fileId = fopen(fileName, 'r');

subSampleMat = [1, 1; 1, 1];
nrFrame = length(idxFrame);

for f = 1 : 1 : nrFrame
    % search fileId position
    sizeFrame = 1.5 * width * height;
    fseek(fileId, (idxFrame(f) - 1) * sizeFrame, 'bof');
    
    % read Y component
    buf = fread(fileId, width * height, 'uchar');
    imgYuv(:, :, 1) = reshape(buf, width, height).'; % reshape
    
    % read U component
    buf = fread(fileId, width / 2 * height / 2, 'uchar');
    imgYuv(:, :, 2) = kron(reshape(buf, width / 2, height / 2).', subSampleMat); % reshape and upsample
    
    % read V component
    buf = fread(fileId, width / 2 * height / 2, 'uchar');
    imgYuv(:, :, 3) = kron(reshape(buf, width / 2, height / 2).', subSampleMat); % reshape and upsample
    

    % normalize YUV values
    % imgYuv = imgYuv / 255;
    
    % convert YUV to RGB
    % imgRgb = reshape(convertYuvToRgb(reshape(imgYuv, height * width, 3)), height, width, 3);
    % mov(f) = im2frame(imgRgb);
    mov(f).imgYuv = imgYuv;

end
fclose(fileId);