function exch2_setup_cs6_print( domain, tile, tnx, tny, mapIO, ntile)
% Write out tile attributes in a structured format
% Use fixed format Fortran for now
% 1 - many routines in one big file
% 2 - many routines in many files
outmode=1;
%outmode=2;
outdir='./';

% $Header$
% $Name$

% Output unit
fnam=sprintf('%s%s',outdir,'w2_e2setup.F');
fnamh=sprintf('%s%s',outdir,'W2_EXCH2_TOPOLOGY.h');
fout=fopen(fnam,'w');
fouth=fopen(fnamh,'w');

% Declare data structures ti hold the information

if mapIO == -1,
  global_nx = sum([domain(:).dnx]);
  global_ny = max([domain(:).dny]);
elseif mapIO == 0,
  global_nx = sum([domain(:).dnx].*[domain(:).dny]);
  global_ny = 1 ;
% error(' long line format incompatible with size=domain_nyt*tny ')
else
  global_nx = mapIO ;
  global_ny = sum([domain(:).dnx].*[domain(:).dny])/mapIO ;
end
domain_nxt = round(global_nx/tnx);
domain_nyt = round(global_ny/tny);
fprintf(' domain_nxt = %i , domain_nyt = %i\n',domain_nxt,domain_nyt)
%- MITgcm currently specifies global size in tile-size units:
%  (domain_nxt,domain_nyt). If this is not possible, decide to stop.
%  Note: this happen only with long-line formap (mapIO=0).
if global_nx ~= domain_nxt*tnx | global_ny ~= domain_nyt*tny ,
  error(' Global domain size is not a multiple of tile size !');
end

% Figure out maximum number of neighbors any tile has
nNeighbors=0;
for j=1:length(tile)
 myNeighborCount=sum(tile(j).nW+tile(j).nN+tile(j).nE+tile(j).nS);
 nNeighbors=max(nNeighbors,myNeighborCount);
end

% Create header file
fprintf(fouth,'C      *** THIS FILE IS AUTOMATICALLY GENERATED ***\n');
fprintf(fouth,'C---   Tiling topology data structures header file\n');
fprintf(fouth,'C      NTILES            :: Number of tiles in this topology \n');
fprintf(fouth,'C      MAX_NEIGHBOURS    :: Maximum number of neighbours any tile has.\n');
fprintf(fouth,'C      exch2_domain_nxt  :: Total domain length in tiles. \n');
fprintf(fouth,'C      exch2_domain_nyt  :: Maximum domain height in tiles. \n');
fprintf(fouth,'C      exch2_global_Nx   :: Global-file domain length.\n');
fprintf(fouth,'C      exch2_global_Ny   :: Global-file domain height.\n');
fprintf(fouth,'C      exch2_tNx         :: Size in X for each tile.\n');
fprintf(fouth,'C      exch2_tNy         :: Size in Y for each tile.\n');
fprintf(fouth,'C      exch2_tBasex      :: Tile offset in X within its sub-domain (cube face)\n');
fprintf(fouth,'C      exch2_tBasey      :: Tile offset in Y within its sub-domain (cube face)\n');
fprintf(fouth,'C      exch2_txGlobalo   :: Tile base X index within global index space.\n');
fprintf(fouth,'C      exch2_tyGlobalo   :: Tile base Y index within global index space.\n');
fprintf(fouth,'C      exch2_isWedge     :: 1 if West  is at domain edge, 0 if not.\n');
fprintf(fouth,'C      exch2_isNedge     :: 1 if North is at domain edge, 0 if not.\n');
fprintf(fouth,'C      exch2_isEedge     :: 1 if East  is at domain edge, 0 if not.\n');
fprintf(fouth,'C      exch2_isSedge     :: 1 if South is at domain edge, 0 if not.\n');
fprintf(fouth,'C      exch2_myFace      :: Face number for each tile (used for I/O).\n');
fprintf(fouth,'C      exch2_mydNx       :: Face size in X for each tile (for I/O).\n');
fprintf(fouth,'C      exch2_mydNy       :: Face size in Y for each tile (for I/O).\n');
fprintf(fouth,'C      exch2_tProc       :: Rank of process owning tile (filled at run time).\n');
fprintf(fouth,'C      exch2_nNeighbours :: Tile neighbour entries count.\n');
fprintf(fouth,'C      exch2_neighbourId :: Tile number for each neighbour entry.\n');
fprintf(fouth,'C      exch2_opposingSend:: Neighbour entry in target tile send \n');
fprintf(fouth,'C                        :: which has this tile and neighbour as its target.\n');
fprintf(fouth,'C      exch2_pij(:,n,t)  :: Matrix which applies to target-tile indices to get\n'); 
fprintf(fouth,'C                        :: source-tile "t" indices, for neighbour entry "n".\n');
fprintf(fouth,'C      exch2_oi(n,t)     :: Source-tile "t" X index offset in target\n');
fprintf(fouth,'C                        :: to source connection (neighbour entry "n").\n'); 
fprintf(fouth,'C      exch2_oj(n,t)     :: Source-tile "t" Y index offset in target\n');
fprintf(fouth,'C                        :: to source connection (neighbour entry "n").\n'); 
fprintf(fouth,'       INTEGER NTILES\n');
fprintf(fouth,'       INTEGER MAX_NEIGHBOURS\n');
fprintf(fouth,'       INTEGER exch2_domain_nyt\n');
fprintf(fouth,'       INTEGER exch2_domain_nxt\n');
fprintf(fouth,'       INTEGER exch2_global_Nx\n');
fprintf(fouth,'       INTEGER exch2_global_Ny\n');
fprintf(fouth,'       PARAMETER ( NTILES = %d)\n',length(tile));
fprintf(fouth,'       PARAMETER ( MAX_NEIGHBOURS = %d)\n',nNeighbors);
fprintf(fouth,'       PARAMETER ( exch2_domain_nxt=%d)\n',domain_nxt);
fprintf(fouth,'       PARAMETER ( exch2_domain_nyt=%d)\n',domain_nyt);
fprintf(fouth,'       PARAMETER ( exch2_global_Nx = %d)\n',global_nx);
fprintf(fouth,'       PARAMETER ( exch2_global_Ny = %d)\n',global_ny);
fprintf(fouth,'       INTEGER exch2_tNx(NTILES)\n');
fprintf(fouth,'       INTEGER exch2_tNy(NTILES)\n');
fprintf(fouth,'       INTEGER exch2_tBasex(NTILES)\n');
fprintf(fouth,'       INTEGER exch2_tBasey(NTILES)\n');
fprintf(fouth,'       INTEGER exch2_txGlobalo(NTILES)\n');
fprintf(fouth,'       INTEGER exch2_tyGlobalo(NTILES)\n');
fprintf(fouth,'       INTEGER exch2_isWedge(NTILES)\n');
fprintf(fouth,'       INTEGER exch2_isNedge(NTILES)\n');
fprintf(fouth,'       INTEGER exch2_isEedge(NTILES)\n');
fprintf(fouth,'       INTEGER exch2_isSedge(NTILES)\n');
fprintf(fouth,'       INTEGER exch2_myFace(NTILES)\n');
fprintf(fouth,'       INTEGER exch2_mydNx(NTILES)\n');
fprintf(fouth,'       INTEGER exch2_mydNy(NTILES)\n');
fprintf(fouth,'       INTEGER exch2_tProc(NTILES)\n');
fprintf(fouth,'       INTEGER exch2_nNeighbours(NTILES)\n');
fprintf(fouth,'       INTEGER exch2_neighbourId(MAX_NEIGHBOURS,NTILES)\n');
fprintf(fouth,'       INTEGER exch2_opposingSend(MAX_NEIGHBOURS,NTILES)\n');
fprintf(fouth,'       INTEGER exch2_pij(4,MAX_NEIGHBOURS,NTILES)\n');
fprintf(fouth,'       INTEGER exch2_oi(MAX_NEIGHBOURS,NTILES)\n');
fprintf(fouth,'       INTEGER exch2_oj(MAX_NEIGHBOURS,NTILES)\n');
fprintf(fouth,'\n');
fprintf(fouth,'       COMMON /W2_EXCH2_TOPO_I/\n');
fprintf(fouth,'     &        exch2_tNx, exch2_tNy,\n');
fprintf(fouth,'     &        exch2_tBasex, exch2_tBasey,\n');
fprintf(fouth,'     &        exch2_txGlobalo,exch2_tyGlobalo,\n');
fprintf(fouth,'     &        exch2_isWedge, exch2_isNedge,\n');
fprintf(fouth,'     &        exch2_isEedge, exch2_isSedge,\n');
fprintf(fouth,'     &        exch2_myFace, exch2_mydNx, exch2_mydNy,\n');
fprintf(fouth,'     &        exch2_tProc,\n');
fprintf(fouth,'     &        exch2_nNeighbours, exch2_neighbourId,\n');
fprintf(fouth,'     &        exch2_opposingSend,\n');
fprintf(fouth,'     &        exch2_pij,\n');
fprintf(fouth,'     &        exch2_oi, exch2_oj\n');
fprintf(fouth,'\n');
fprintf(fouth,'C---   Exchange execution loop data structures\n');
fprintf(fouth,'C      exch2_iLo,iHi(n,t) :: X-index range of this tile "t" halo-region\n');
fprintf(fouth,'C                         :: to be updated with neighbour entry "n".\n');
fprintf(fouth,'C      exch2_jLo,jHi(n,t) :: Y-index range of this tile "t" halo-region\n');
fprintf(fouth,'C                         :: to be updated with neighbour entry "n".\n');
fprintf(fouth,'       INTEGER exch2_iLo(MAX_NEIGHBOURS,NTILES)\n');
fprintf(fouth,'       INTEGER exch2_iHi(MAX_NEIGHBOURS,NTILES)\n');
fprintf(fouth,'       INTEGER exch2_jLo(MAX_NEIGHBOURS,NTILES)\n');
fprintf(fouth,'       INTEGER exch2_jHi(MAX_NEIGHBOURS,NTILES)\n');
fprintf(fouth,'       COMMON /W2_EXCH2_HALO_SPEC/\n');
fprintf(fouth,'     &        exch2_iLo, exch2_iHi,\n');
fprintf(fouth,'     &        exch2_jLo, exch2_jHi\n');
fprintf(fouth,'\n');
fprintf(fout,'C      *** THIS FILE IS AUTOMATICALLY GENERATED ***\n');
fprintf(fout,'       SUBROUTINE W2_E2SETUP\n');
fprintf(fout,'\n');
fprintf(fout,'C      Tile toplogy settings data structures\n');
fprintf(fout,'#include "W2_EXCH2_TOPOLOGY.h"\n');
fprintf(fout,'\n');

% Settings
fprintf(fout,'C      Tile settings table\n');
for j=1:length(tile), if tile(j).tileid > 0,
fprintf(fout,'       CALL W2_E2SETUP_%d\n',j);
end ; end
fprintf(fout,'       RETURN\n');
fprintf(fout,'       END\n');
fprintf(fout,'\n');
if outmode == 2
fclose(fout);
end

for j=1:length(tile), if tile(j).tileid > 0,
if outmode == 2
fnam=sprintf('w2_e2setup_%d.F',j);
fnamf=sprintf('%s%s',outdir,fnam);
fout=fopen(fnamf,'w');
end
fprintf(fout,'       SUBROUTINE W2_E2SETUP_%d\n',j);
fprintf(fout,'C      Topology for tile %d\n',j);
fprintf(fout,'#include "W2_EXCH2_TOPOLOGY.h"\n');
fprintf(fout,'       exch2_tNx(%d)=%d\n',j,tile(j).tnx);
fprintf(fout,'       exch2_tNy(%d)=%d\n',j,tile(j).tny);
fprintf(fout,'       exch2_tBasex(%d)=%d\n',j,tile(j).tbasex);
fprintf(fout,'       exch2_tBasey(%d)=%d\n',j,tile(j).tbasey);
fprintf(fout,'       exch2_txGlobalo(%d)=%d\n',j,tile(j).txgloballo);
fprintf(fout,'       exch2_tyGlobalo(%d)=%d\n',j,tile(j).tygloballo);
fprintf(fout,'       exch2_isWedge(%d)=%d\n',j,tile(j).isWedge);
fprintf(fout,'       exch2_isNedge(%d)=%d\n',j,tile(j).isNedge);
fprintf(fout,'       exch2_isEedge(%d)=%d\n',j,tile(j).isEedge);
fprintf(fout,'       exch2_isSedge(%d)=%d\n',j,tile(j).isSedge);
fprintf(fout,'       exch2_myFace(%d)=%d\n',j,tile(j).mydomain);
fprintf(fout,'       exch2_mydNx(%d)=%d\n',j,domain(tile(j).mydomain).dnx);
fprintf(fout,'       exch2_mydNy(%d)=%d\n',j,domain(tile(j).mydomain).dny);
myNeighborCount=sum(tile(j).nW+tile(j).nN+tile(j).nE+tile(j).nS);
fprintf(fout,'       exch2_nNeighbours(%d)=%d\n',j,myNeighborCount);
in=0;

for n=1:tile(j).nN
 % Find corresponding target tile send entry from which I will receive
 % Need to know the send tiles edge, since same tile could send to this tile
 % from multiple edges. However there is only one send per remote tile for
 % any single edge.
 targetTile=tile(j).nTile(n);
 if tile(j).n_pi(n,:) == [0 -1] & tile(j).n_pj(n,:) == [ 1 0]
  % Send will be from targets west edge, find this tile in targets north edge list
  for k=1:tile(targetTile).nW
   if tile(targetTile).wTile(k) == j
    local_iLo=tile(targetTile).w_itlo_l(k);
    local_iHi=tile(targetTile).w_ithi_l(k);
    local_jLo=tile(targetTile).w_jtlo_l(k);
    local_jHi=tile(targetTile).w_jthi_l(k);
    % Formula for ir assumes tiles neighbors are written nW, nN, nE, nS
    ir=k;
    % Formula for ir assumes tiles neighbors are written nN, nS, nE, nW
    ir=tile(targetTile).nN+tile(targetTile).nS+tile(targetTile).nE+k;
   end
  end
 elseif tile(j).n_pi(n,:) == [1 0] & tile(j).n_pj(n,:) == [0 1]
  % Send wil be from targets south edge, find this tile in targets south edge list
  for k=1:tile(targetTile).nS
   if tile(targetTile).sTile(k) == j
    local_iLo=tile(targetTile).s_itlo_l(k);
    local_iHi=tile(targetTile).s_ithi_l(k);
    local_jLo=tile(targetTile).s_jtlo_l(k);
    local_jHi=tile(targetTile).s_jthi_l(k);
    % Formula for ir assumes tiles neighbors are written nW, nN, nE, nS
    ir=tile(targetTile).nW+tile(targetTile).nN+tile(targetTile).nE+k;
    % Formula for ir assumes tiles neighbors are written nN, nS, nE, nW
    ir=tile(targetTile).nN+k;
   end
  end
 else
  fprintf(fout,'ERROR MISSING CASE IN GENERATING CODE\n');
 end
 fprintf(fout,'\n');
 in=in+1;
 fprintf(fout,'       exch2_neighbourId(%d,%d)=%d\n',in,j,tile(j).nTile(n));
 fprintf(fout,'       exch2_iLo(%d,%d)=%d\n',in,j,local_iLo);
 fprintf(fout,'       exch2_iHi(%d,%d)=%d\n',in,j,local_iHi);
 fprintf(fout,'       exch2_jLo(%d,%d)=%d\n',in,j,local_jLo);
 fprintf(fout,'       exch2_jHi(%d,%d)=%d\n',in,j,local_jHi);
 fprintf(fout,'       exch2_opposingSend(%d,%d)=%d\n',in,j,ir);
 fprintf(fout,'       exch2_pij(1,%d,%d)=%d\n',in,j,tile(j).n_pi(n,1));
 fprintf(fout,'       exch2_pij(2,%d,%d)=%d\n',in,j,tile(j).n_pi(n,2));
 fprintf(fout,'       exch2_pij(3,%d,%d)=%d\n',in,j,tile(j).n_pj(n,1));
 fprintf(fout,'       exch2_pij(4,%d,%d)=%d\n',in,j,tile(j).n_pj(n,2));
 fprintf(fout,'       exch2_oi(%d,%d)=%d\n',in,j,tile(j).n_oi(n));
%fprintf(fout,'       exch2_oi_f(%d,%d)=%d\n',in,j,tile(j).n_oi_f(n));
 fprintf(fout,'       exch2_oj(%d,%d)=%d\n',in,j,tile(j).n_oj(n));
%fprintf(fout,'       exch2_oj_f(%d,%d)=%d\n',in,j,tile(j).n_oj_f(n));
%fprintf(fout,'       exch2_itlo_c(%d,%d)=%d\n',in,j,tile(j).n_itlo_l(n));
%fprintf(fout,'       exch2_ithi_c(%d,%d)=%d\n',in,j,tile(j).n_ithi_l(n));
%fprintf(fout,'       exch2_jtlo_c(%d,%d)=%d\n',in,j,tile(j).n_jtlo_l(n));
%fprintf(fout,'       exch2_jthi_c(%d,%d)=%d\n',in,j,tile(j).n_jthi_l(n));
end

for n=1:tile(j).nS
 % Find corresponding target tile send entry from which I will receive
 % Need to know the send tiles edge, since same tile could send to this tile
 % from multiple edges. However there is only one send per remote tile for
 % any single edge.
 targetTile=tile(j).sTile(n);
 if tile(j).s_pi(n,:) == [0 -1] & tile(j).s_pj(n,:) == [ 1 0]
  % Opposing send wil be from targets east edge, find this tile in targets east edge list
  for k=1:tile(targetTile).nE
   if tile(targetTile).eTile(k) == j
    local_iLo=tile(targetTile).e_itlo_l(k);
    local_iHi=tile(targetTile).e_ithi_l(k);
    local_jLo=tile(targetTile).e_jtlo_l(k);
    local_jHi=tile(targetTile).e_jthi_l(k);
    % Formula for ir assumes tiles neighbors are written nW, nN, nE, nS
    ir=tile(targetTile).nW+tile(targetTile).nN+k;
    % Formula for ir assumes tiles neighbors are written nN, nS, nE, nW
    ir=tile(targetTile).nN+tile(targetTile).nS+k;
   end
  end
 elseif tile(j).s_pi(n,:) == [1 0] & tile(j).s_pj(n,:) == [0 1]
  % Opposing send wil be from targets north edge, find this tile in targets north edge list
  for k=1:tile(targetTile).nN
   if tile(targetTile).nTile(k) == j
    local_iLo=tile(targetTile).n_itlo_l(k);
    local_iHi=tile(targetTile).n_ithi_l(k);
    local_jLo=tile(targetTile).n_jtlo_l(k);
    local_jHi=tile(targetTile).n_jthi_l(k);
    % Formula for ir assumes tiles neighbors are written nW, nN, nE, nS
    ir=tile(targetTile).nW+k;
    % Formula for ir assumes tiles neighbors are written nN, nS, nE, nW
    ir=k;
   end
  end
 else
  fprintf(fout,'ERROR MISSING CASE IN GENERATING CODE\n');
 end
 fprintf(fout,'\n');
 in=in+1;
 fprintf(fout,'       exch2_neighbourId(%d,%d)=%d\n',in,j,tile(j).sTile(n));
 fprintf(fout,'       exch2_iLo(%d,%d)=%d\n',in,j,local_iLo);
 fprintf(fout,'       exch2_iHi(%d,%d)=%d\n',in,j,local_iHi);
 fprintf(fout,'       exch2_jLo(%d,%d)=%d\n',in,j,local_jLo);
 fprintf(fout,'       exch2_jHi(%d,%d)=%d\n',in,j,local_jHi);
 fprintf(fout,'       exch2_opposingSend(%d,%d)=%d\n',in,j,ir);
 fprintf(fout,'       exch2_pij(1,%d,%d)=%d\n',in,j,tile(j).s_pi(n,1));
 fprintf(fout,'       exch2_pij(2,%d,%d)=%d\n',in,j,tile(j).s_pi(n,2));
 fprintf(fout,'       exch2_pij(3,%d,%d)=%d\n',in,j,tile(j).s_pj(n,1));
 fprintf(fout,'       exch2_pij(4,%d,%d)=%d\n',in,j,tile(j).s_pj(n,2));
 fprintf(fout,'       exch2_oi(%d,%d)=%d\n',in,j,tile(j).s_oi(n));
%fprintf(fout,'       exch2_oi_f(%d,%d)=%d\n',in,j,tile(j).s_oi_f(n));
 fprintf(fout,'       exch2_oj(%d,%d)=%d\n',in,j,tile(j).s_oj(n));
%fprintf(fout,'       exch2_oj_f(%d,%d)=%d\n',in,j,tile(j).s_oj_f(n));
%fprintf(fout,'       exch2_itlo_c(%d,%d)=%d\n',in,j,tile(j).s_itlo_l(n));
%fprintf(fout,'       exch2_ithi_c(%d,%d)=%d\n',in,j,tile(j).s_ithi_l(n));
%fprintf(fout,'       exch2_jtlo_c(%d,%d)=%d\n',in,j,tile(j).s_jtlo_l(n));
%fprintf(fout,'       exch2_jthi_c(%d,%d)=%d\n',in,j,tile(j).s_jthi_l(n));
end

for n=1:tile(j).nE
 % Find corresponding target tile send entry from which I will receive
 % Need to know the send tiles edge, since same tile could send to this tile
 % from multiple edges. However there is only one send per remote tile for
 % any single edge.
 targetTile=tile(j).eTile(n);
 if tile(j).e_pi(n,:) == [0 1] & tile(j).e_pj(n,:) == [-1 0]
  % Opposing send wil be from targets south edge, find this tile in targets south edge list
  for k=1:tile(targetTile).nS
   if tile(targetTile).sTile(k) == j
    local_iLo=tile(targetTile).s_itlo_l(k);
    local_iHi=tile(targetTile).s_ithi_l(k);
    local_jLo=tile(targetTile).s_jtlo_l(k);
    local_jHi=tile(targetTile).s_jthi_l(k);
    % Formula for ir assumes tiles neighbors are written nW, nN, nE, nS
    ir=tile(targetTile).nW+tile(targetTile).nN+tile(targetTile).nE+k;
    % Formula for ir assumes tiles neighbors are written nN, nS, nE, nW
    ir=tile(targetTile).nN+k;
   end
  end
 elseif tile(j).e_pi(n,:) == [1 0] & tile(j).e_pj(n,:) == [0 1]
  % Opposing send wil be from targets west edge, find this tile in targets west edge list
  for k=1:tile(targetTile).nW
   if tile(targetTile).wTile(k) == j
    local_iLo=tile(targetTile).w_itlo_l(k);
    local_iHi=tile(targetTile).w_ithi_l(k);
    local_jLo=tile(targetTile).w_jtlo_l(k);
    local_jHi=tile(targetTile).w_jthi_l(k);
    % Formula for ir assumes tiles neighbors are written nW, nN, nE, nS
    ir=k;
    % Formula for ir assumes tiles neighbors are written nN, nS, nE, nW
    ir=tile(targetTile).nN+tile(targetTile).nS+tile(targetTile).nE+k;
   end
  end
 else
  fprintf(fout,'ERROR MISSING CASE IN GENERATING CODE\n');
 end
 fprintf(fout,'\n');
 in=in+1;
 fprintf(fout,'       exch2_neighbourId(%d,%d)=%d\n',in,j,tile(j).eTile(n));
 fprintf(fout,'       exch2_iLo(%d,%d)=%d\n',in,j,local_iLo);
 fprintf(fout,'       exch2_iHi(%d,%d)=%d\n',in,j,local_iHi);
 fprintf(fout,'       exch2_jLo(%d,%d)=%d\n',in,j,local_jLo);
 fprintf(fout,'       exch2_jHi(%d,%d)=%d\n',in,j,local_jHi);
 fprintf(fout,'       exch2_opposingSend(%d,%d)=%d\n',in,j,ir);
 fprintf(fout,'       exch2_pij(1,%d,%d)=%d\n',in,j,tile(j).e_pi(n,1));
 fprintf(fout,'       exch2_pij(2,%d,%d)=%d\n',in,j,tile(j).e_pi(n,2));
 fprintf(fout,'       exch2_pij(3,%d,%d)=%d\n',in,j,tile(j).e_pj(n,1));
 fprintf(fout,'       exch2_pij(4,%d,%d)=%d\n',in,j,tile(j).e_pj(n,2));
 fprintf(fout,'       exch2_oi(%d,%d)=%d\n',in,j,tile(j).e_oi(n));
%fprintf(fout,'       exch2_oi_f(%d,%d)=%d\n',in,j,tile(j).e_oi_f(n));
 fprintf(fout,'       exch2_oj(%d,%d)=%d\n',in,j,tile(j).e_oj(n));
%fprintf(fout,'       exch2_oj_f(%d,%d)=%d\n',in,j,tile(j).e_oj_f(n));
%fprintf(fout,'       exch2_itlo_c(%d,%d)=%d\n',in,j,tile(j).e_itlo_l(n));
%fprintf(fout,'       exch2_ithi_c(%d,%d)=%d\n',in,j,tile(j).e_ithi_l(n));
%fprintf(fout,'       exch2_jtlo_c(%d,%d)=%d\n',in,j,tile(j).e_jtlo_l(n));
%fprintf(fout,'       exch2_jthi_c(%d,%d)=%d\n',in,j,tile(j).e_jthi_l(n));
end

for n=1:tile(j).nW
 % Find corresponding target tile send entry from which I will receive
 % Need to know the send tiles edge, since same tile could send to this tile
 % from multiple edges. However there is only one send per remote tile for
 % any single edge.
 targetTile=tile(j).wTile(n);
 if tile(j).w_pi(n,:) == [0 1] & tile(j).w_pj(n,:) == [-1 0]
  % Send wil be from targets north edge, find this tile in targets north edge list
  for k=1:tile(targetTile).nN
   if tile(targetTile).nTile(k) == j
    local_iLo=tile(targetTile).n_itlo_l(k);
    local_iHi=tile(targetTile).n_ithi_l(k);
    local_jLo=tile(targetTile).n_jtlo_l(k);
    local_jHi=tile(targetTile).n_jthi_l(k);
    % Formula for ir assumes tiles neighbors are written nW, nN, nE, nS
    ir=tile(targetTile).nW+k;
    % Formula for ir assumes tiles neighbors are written nN, nS, nE, nW
    ir=k;
   end
  end
 elseif tile(j).w_pi(n,:) == [1 0] & tile(j).w_pj(n,:) == [0 1]
  % Send wil be from targets east edge, find this tile in targets east edge list
  for k=1:tile(targetTile).nE
   if tile(targetTile).eTile(k) == j
    local_iLo=tile(targetTile).e_itlo_l(k);
    local_iHi=tile(targetTile).e_ithi_l(k);
    local_jLo=tile(targetTile).e_jtlo_l(k);
    local_jHi=tile(targetTile).e_jthi_l(k);
    % Formula for ir assumes tiles neighbors are written nW, nN, nE, nS
    ir=tile(targetTile).nW+tile(targetTile).nN+k;
    % Formula for ir assumes tiles neighbors are written nN, nS, nE, nW
    ir=tile(targetTile).nN+tile(targetTile).nS+k;
   end
  end
 else
  fprintf(fout,'ERROR MISSING CASE IN GENERATING CODE\n');
 end
 fprintf(fout,'\n');
 in=in+1;
 fprintf(fout,'       exch2_neighbourId(%d,%d)=%d\n',in,j,tile(j).wTile(n));
 fprintf(fout,'       exch2_iLo(%d,%d)=%d\n',in,j,local_iLo);
 fprintf(fout,'       exch2_iHi(%d,%d)=%d\n',in,j,local_iHi);
 fprintf(fout,'       exch2_jLo(%d,%d)=%d\n',in,j,local_jLo);
 fprintf(fout,'       exch2_jHi(%d,%d)=%d\n',in,j,local_jHi);
 fprintf(fout,'       exch2_opposingSend(%d,%d)=%d\n',in,j,ir);
 fprintf(fout,'       exch2_pij(1,%d,%d)=%d\n',in,j,tile(j).w_pi(n,1));
 fprintf(fout,'       exch2_pij(2,%d,%d)=%d\n',in,j,tile(j).w_pi(n,2));
 fprintf(fout,'       exch2_pij(3,%d,%d)=%d\n',in,j,tile(j).w_pj(n,1));
 fprintf(fout,'       exch2_pij(4,%d,%d)=%d\n',in,j,tile(j).w_pj(n,2));
 fprintf(fout,'       exch2_oi(%d,%d)=%d\n',in,j,tile(j).w_oi(n));
%fprintf(fout,'       exch2_oi_f(%d,%d)=%d\n',in,j,tile(j).w_oi_f(n));
 fprintf(fout,'       exch2_oj(%d,%d)=%d\n',in,j,tile(j).w_oj(n));
%fprintf(fout,'       exch2_oj_f(%d,%d)=%d\n',in,j,tile(j).w_oj_f(n));
%fprintf(fout,'       exch2_itlo_c(%d,%d)=%d\n',in,j,tile(j).w_itlo_l(n));
%fprintf(fout,'       exch2_ithi_c(%d,%d)=%d\n',in,j,tile(j).w_ithi_l(n));
%fprintf(fout,'       exch2_jtlo_c(%d,%d)=%d\n',in,j,tile(j).w_jtlo_l(n));
%fprintf(fout,'       exch2_jthi_c(%d,%d)=%d\n',in,j,tile(j).w_jthi_l(n));
end

fprintf(fout,'       RETURN\n');
fprintf(fout,'       END\n');
fprintf(fout,'\n');
if outmode == 2
fclose(fout);
end
end ; end
%fprintf(fout,'       exch2_pi(%d,1)=%d\n',j,tile(j).w_pi(1,1));
%fprintf(fout,'       exch2_pi(%d,2)=%d\n',j,tile(j).w_pi(1,2));
%end

%fprintf(fout,'       RETURN                                     \n');
%fprintf(fout,'       END                                        \n');
if outmode == 1
fclose(fout);
end

%fout=fopen('test.F','w');
%for j=1:length(tile)
% fprintf(fout,'       exch2_jthi_c(%d,%d)=%d\n',in,j,tile(j).s_jthi_l(n));
%end

return
