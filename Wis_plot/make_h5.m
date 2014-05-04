function make_h5(fname,grd,stat,onlns,spec)

if str2num(stat(3:end)) >= 80000
    fbase = ['/station_wis/',stat];
    fonlns = [fbase,'/onlns'];
    fspec = [fbase,'/spe2d'];
else
    fbase = ['/station_buoy/',grd,'/',stat];
    fonlns = [fbase,'/onlns'];
    fspec = [fbase,'/spe2d'];
end

vars = {'wspd';'wind_dir';'wvht_tot';'tp_tot';'tpp_tot';'tm_tot'; ...
    'tm1_tot';'tm2_tot';'mdir_tot';'sprd_tot';'wvht_sea';'tp_sea'; ...
    'tpp_sea';'tm_sea';'tm1_sea';'tm2_sea';'mdir_sea';'sprd_sea'; ...
    'wvht_swe';'tp_swe';'tpp_swe';'tm_swe';'tm1_swe';'tm2_swe'; ...
    'mdir_swe';'sprd_swe'};
longn = {'Wind_Speed';'Wind_Direction';'Total_Wave_Height'; ...
    'Total_Peak_Period';'Total_Parabolic_Fit_Peak_Period'; ...
    'Total_Mean_Period';'Total_1st_Moment_Mean_Period'; ...
    'Total_2nd_Moment_Mean_Period';'Total_Mean_Wave_Direction'; ...
    'Total_Wave_Direction_Spreading';'Windea_Wave_Height'; ...
    'Windsea_Peak_Period';'Windsea_Parabolic_Fit_Peak_Period'; ...
    'Windsea_Mean_Period';'Windsea_1st_Moment_Mean_Period'; ...
    'Windsea_2nd_Moment_Mean_Period';'Windsea_Mean_Wave_Direction'; ...
    'Windsea_Wave_Direction_Spreading';'Swell_Wave_Height'; ...
    'Swell_Peak_Period';'Swell_Parabolic_Fit_Peak_Period'; ...
    'Swell_Mean_Period';'Swell_1st_Moment_Mean_Period'; ...
    'Swell_2nd_Moment_Mean_Period';'Swell_Mean_Wave_Direction'; ...
    'Swell_Wave_Direction_Spreading'};
units = {'m/s';'deg';'m';'s';'s';'s';'s';'s';'deg';'deg';'m';'s';'s'; ...
    's';'s';'s';'deg';'deg';'m';'s';'s';'s';'s';'s';'deg';'deg'};
vid = [5,6,10:34];

for ivar = 1:size(vars,1)
    h5create(fname,[fonlns,'/',vars{ivar}],[1 length(onlns)], ...
        'FillValue',-999.99,'Datatype','double');%,'ChunkSize',[1 length(onlns)], ...
        %'Deflate',9);
    %h5create(fname,[fonlns,'/',vars{ivar}],[1 1],'FillValue',-999.99,'ChunkSize',[1 1],'Deflate',9);
    h5write(fname,[fonlns,'/',vars{ivar}],onlns(:,vid(ivar))');
    h5writeatt(fname,[fonlns,'/',vars{ivar}],'Long_Name',longn{ivar})
    h5writeatt(fname,[fonlns,'/',vars{ivar}],'Units',units{ivar});
end

h5create(fname,[fspec,'/freq'],[1 spec(1).nf]);
h5write(fname,[fspec,'/freq'],spec(1).freq);

h5create(fname,[fspec,'/direc'],[1 spec(1).na]);
h5write(fname,[fspec,'/direc'],spec(1).ang);

for zz = 1:size(spec,2)
    ef(:,:,zz) = spec(zz).ef2d;
end

h5create(fname,[fspec,'/ef2d'],[spec(1).nf spec(1).na length(onlns)]);%, ...
   % 'ChunkSize',[spec(1).nf spec(1).na 10],'Deflate',9);
h5write(fname,[fspec,'/ef2d'],ef);

h5writeatt(fname,fbase,'longitude',spec(1).lon);
h5writeatt(fname,fbase,'latitude',spec(1).lat);



