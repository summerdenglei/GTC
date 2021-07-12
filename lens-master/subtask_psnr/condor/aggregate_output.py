input_dir = "/u/yichao/anomaly_compression/condor_data/subtask_psnr/condor/output/"
output_dir = "/u/yichao/anomaly_compression/condor_data/subtask_psnr/condor/"

#####################################
## 1. DCT_psnr: 4sq TM
print "DCT"
fh_out = open(output_dir + "DCT_psnr.txt", "w")
for video_name in ["TM_Airport_period5_", "TM_Austin_period5_", "TM_Manhattan_period5_", "TM_San_Francisco_period5_"]:
    for grp_size in [4, 8, 12, 16]:
        for num_chunks in [5, 10, 15, 20, 30, 40, 50, 60, 70, 80, 90, 100, 150, 200]:
            for num_frames in [12]:

                if video_name == "TM_Manhattan_period5_":
                    width = 500
                    height = 500
                else:
                    width = 300
                    height = 300
                
                file_name = input_dir + "DCT_psnr." + video_name + "." + str(grp_size) + "." + str(num_chunks) + "." + str(num_frames) + "." + str(width) + "." + str(height) + ".txt"
                # print file_name

                fh = open(file_name, 'r');
                for line in fh:
                    ret = line.split(', ');
                    ratio = float(ret[0]);
                    psnr = float(ret[1]);

                    print video_name + ", " + str(grp_size) + ", " + str(num_chunks) + ", " + str(num_frames) + ", " + str(width) + ", " + str(height) + ", " + str(ratio) + ", " + str(psnr)
                    buf = video_name + ", " + str(grp_size) + ", " + str(num_chunks) + ", " + str(num_frames) + ", " + str(width) + ", " + str(height) + ", " + str(ratio) + ", " + str(psnr) + "\n"
                    fh_out.write(buf)
                fh.close()
fh_out.close()


#####################################
## 2. compressive_sensing_psnr: 4sq TM
print "compressive sensing"
fh_out = open(output_dir + "compressive_sensing_psnr.txt", "w")
for video_name in ["TM_Airport_period5_", "TM_Austin_period5_", "TM_Manhattan_period5_", "TM_San_Francisco_period5_"]:
    for grp_size in [4, 8, 12, 16]:
        for rank in [5, 10, 15, 20, 25, 30, 35, 40]:
            for num_frames in [12]:

                if video_name == "TM_Manhattan_period5_":
                    width = 500
                    height = 500
                else:
                    width = 300
                    height = 300
                
                file_name = input_dir + "compressive_sensing_psnr." + video_name + "." + str(grp_size) + "." + str(rank) + "." + str(num_frames) + "." + str(width) + "." + str(height) + ".txt"
                # print file_name

                fh = open(file_name, 'r');
                for line in fh:
                    ret = line.split(', ');
                    ratio_srmf = float(ret[0]);
                    psnr_srmf = float(ret[1]);
                    ratio_base = float(ret[2]);
                    psnr_base = float(ret[3]);

                    print video_name + ", " + str(grp_size) + ", " + str(rank) + ", " + str(num_frames) + ", " + str(width) + ", " + str(height) + ", " + str(ratio_srmf) + ", " + str(psnr_srmf) + ", " + str(ratio_base) + ", " + str(psnr_base)
                    buf = video_name + ", " + str(grp_size) + ", " + str(rank) + ", " + str(num_frames) + ", " + str(width) + ", " + str(height) + ", " + str(ratio_srmf) + ", " + str(psnr_srmf) + ", " + str(ratio_base) + ", " + str(psnr_base) + "\n"
                    fh_out.write(buf)
                fh.close()
fh_out.close()


#####################################
## 3. compressive_sensing_psnr2: video
print "compressive sensing2"
fh_out = open(output_dir + "compressive_sensing_psnr2.txt", "w")
for video_name in ["stefan_cif", "bus_cif", "foreman_cif", "coastguard_cif", "highway_cif"]:
    for grp_size in [4, 8, 16]:
        for rank in [5, 10, 15, 20, 25, 30, 35, 40, 50, 60, 70]:
            
            width = 352
            height = 288
            if video_name == "stefan_cif":
                num_frames = 90
            elif video_name == "bus_cif":
                num_frames = 150
            else:
                num_frames = 300
            
            file_name = input_dir + "compressive_sensing_psnr2." + video_name + "." + str(grp_size) + "." + str(rank) + "." + str(num_frames) + "." + str(width) + "." + str(height) + ".txt"
            # print file_name

            fh = open(file_name, 'r');
            for line in fh:
                ret = line.split(', ');
                ratio_srmf = float(ret[0]);
                psnr_srmf = float(ret[1]);
                ratio_base = float(ret[2]);
                psnr_base = float(ret[3]);

                print video_name + ", " + str(grp_size) + ", " + str(rank) + ", " + str(num_frames) + ", " + str(width) + ", " + str(height) + ", " + str(ratio_srmf) + ", " + str(psnr_srmf) + ", " + str(ratio_base) + ", " + str(psnr_base)
                buf = video_name + ", " + str(grp_size) + ", " + str(rank) + ", " + str(num_frames) + ", " + str(width) + ", " + str(height) + ", " + str(ratio_srmf) + ", " + str(psnr_srmf) + ", " + str(ratio_base) + ", " + str(psnr_base) + "\n"
                fh_out.write(buf)
            fh.close()
fh_out.close()