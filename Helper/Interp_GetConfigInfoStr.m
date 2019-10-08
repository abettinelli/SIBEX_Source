function config_info=Interp_GetConfigInfoStr(SrcImageName, DesImageName, ROIImageInfo, ROIImageInfoNew)
config_info = cell(30,1);

config_info{1,:} = SrcImageName;
config_info{2,:} = sprintf('Endian = %d', 0);
config_info{3,:} = 'unsigned short';

config_info{4,:} = sprintf('x_dim = %d', ROIImageInfo.XDim);
config_info{5,:} = sprintf('y_dim = %d', ROIImageInfo.YDim);
config_info{6,:} = sprintf('z_dim = %d', ROIImageInfo.ZDim);

config_info{7,:} = sprintf('x_pixdim = %6.6f', ROIImageInfo.XPixDim);
config_info{8,:} = sprintf('y_pixdim = %6.6f', ROIImageInfo.YPixDim);
config_info{9,:} = sprintf('z_pixdim = %6.6f', ROIImageInfo.ZPixDim);


config_info{10,:} = sprintf('x_start = %6.6f', ROIImageInfo.XStart);
config_info{11,:} = sprintf('y_start = %6.6f', ROIImageInfo.YStart);
config_info{12,:} = sprintf('z_start = %6.6f', ROIImageInfo.ZStart);


config_info{13,:} = DesImageName;
config_info{14,:} = sprintf('Endian = %d',0);
config_info{15,:} = 'unsigned short';

config_info{16,:} = sprintf('x_dim = %d', ROIImageInfoNew.XDim);
config_info{17,:} = sprintf('y_dim = %d', ROIImageInfoNew.YDim);
config_info{18,:} = sprintf('z_dim = %d', ROIImageInfoNew.ZDim);

config_info{19,:} = sprintf('x_pixdim = %6.6f', ROIImageInfoNew.XPixDim);
config_info{20,:} = sprintf('y_pixdim = %6.6f', ROIImageInfoNew.YPixDim);
config_info{21,:} = sprintf('z_pixdim = %6.6f', ROIImageInfoNew.ZPixDim);

config_info{22,:} = sprintf('x_start = %6.6f', ROIImageInfoNew.XStart);
config_info{23,:} = sprintf('y_start = %6.6f', ROIImageInfoNew.YStart);
config_info{24,:} = sprintf('z_start = %6.6f', ROIImageInfoNew.ZStart);


config_info{25,:} = sprintf('thetax = %6.6f', 0);
config_info{26,:} = sprintf('thetay = %6.6f', 0);
config_info{27,:} = sprintf('thetaz = %6.6f', 0);

config_info{28,:} = sprintf('transx = %6.6f',0);
config_info{29,:} = sprintf('transy = %6.6f',0);
config_info{30,:} = sprintf('transz = %6.6f',0);