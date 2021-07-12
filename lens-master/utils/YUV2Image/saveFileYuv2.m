function saveFileYuv2(mov, fileName, mode)
% save RGB movie [0, 255] to YUV 4:2:0 file

switch mode
	case 1 % replace file
		fileId = fopen(fileName, 'w');
	case 2 % append to file
		fileId = fopen(fileName, 'a');
	otherwise
		fileId = fopen(fileName, 'w');
end

nrFrame = length(mov);

for f = 1 : 1 : nrFrame
	imgYuv = mov(f).imgYuv;

	% write Y component
	buf = reshape(imgYuv(:, :, 1).', [], 1); % reshape
	count = fwrite(fileId, buf, 'uchar');
			
	% write U component
	buf = reshape(imgYuv(1 : 2 : end, 1 : 2 : end, 2).', [], 1); % downsample and reshape
	count = fwrite(fileId, buf, 'uchar');

	% write V component
	buf = reshape(imgYuv(1 : 2 : end, 1 : 2 : end, 3).', [], 1); % downsample and reshape
	count = fwrite(fileId, buf, 'uchar');
end

fclose(fileId);

