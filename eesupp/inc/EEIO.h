C $Header$

#ifdef USE_EEIO

C     /==========================================================\
C     | EEIO.h                                                   |
C     |==========================================================|
C     | Support data structures for the MITgcm UV "execution     |
C     | environment" IO code.                                    |
C     \==========================================================/

C--   COMMON /EEIO_R/ IO supporting real arrays
C     tmpXY_R8 - XY Real*8 IO buffer.
C     tmpXY_R4 - XY Real*4 IO buffer.
      COMMON /EESUPP_IO_R/ IO_tmpXY_R8, IO_tmpXY_R4
      Real*8 IO_tmpXY_R8(Nx,Ny)
      Real*4 IO_tmpXY_R4(Nx,Ny)

#endif
