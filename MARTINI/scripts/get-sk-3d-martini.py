#!/usr/bin/python

import numpy as np
import glob,sys
from math import pi
import time

def read_lammpstrj(filedesc):
    # three comment lines
    for i in range(3): comment = filedesc.readline()
    # number of atoms
    natoms = int(filedesc.readline())
    # 1 comment line
    comment = filedesc.readline()
    # assume orthorombic cell
    cell = np.zeros(3,float)
    for i in range(3): 
        [cellmin, cellmax] = filedesc.readline().split()
        cell[i] = float(cellmax) - float(cellmin)
    # 1 comment line
    comment = filedesc.readline()
    types = np.zeros(natoms,int)
    q = np.zeros((natoms,3),float)
    sq = np.zeros((natoms,3),float)

    for i in range(natoms):
        line = filedesc.readline().split()
        types[i] = int(line[1])  # atom type (1 for SP5, 2 for water)
        q[i] = line[2:5] # wrapped atomic coordinates
        sq[i,0] = float(q[i,0])/cell[0] # scaled atomic coordinates
        sq[i,1] = float(q[i,1])/cell[1] # scaled atomic coordinates
        sq[i,2] = float(q[i,2])/cell[2] # scaled atomic coordinates
    return [cell, types, sq]

def Sk(types, q, kgrid):
    # This is the un-normalized FT for the density fluctuations
    q_SP5 = np.asarray([ q_now for i,q_now in enumerate(q) if types[i] == 1 ])
    n_SP5 = len(q_SP5)
    print("Number of SP5 beads: ", n_SP5)
    if n_SP5 > 0:
        FTrho_SP5 = FT_density(q_SP5, kgrid)
    else:
        FTrho_SP5 = np.empty(len(kgrid))
        FTrho_SP5[:] = np.NaN

    q_W = np.asarray([ q_now for i,q_now in enumerate(q) if types[i] == 2 ])
    n_W = len(q_W)
    print("Number of water beads: ", n_W)
    if n_W > 0:
        FTrho_W = FT_density(q_W, kgrid)
    else:
        FTrho_W = np.empty(len(kgrid))
        FTrho_W[:] = np.NaN

    return np.multiply(FTrho_SP5, np.conjugate(FTrho_SP5))/n_SP5, \
           np.multiply(FTrho_SP5, np.conjugate(FTrho_W))/(n_SP5*n_W)**0.5, \
           np.multiply(FTrho_W, np.conjugate(FTrho_W))/n_W

def FT_density(q, kgrid):
    # This is the un-normalized FT for density fluctuations
    ng = len(kgrid)
    ak = np.zeros(ng,dtype=complex)

    for n,k in enumerate(kgrid):
        ak[n] = np.sum(np.exp(-1j*(q[:,0]*k[0]+q[:,1]*k[1]+q[:,2]*k[2])))
    return ak

def main(sprefix="Sk", straj="out", sbins=8):
    # the input file
    print("Reading file:", straj,".lammpstrj")
    traj = open(straj+'.lammpstrj',"r")
    # number of k grids
    bins = int(sbins)
    print("Use number of bins:", bins)

    # Outputs for SP5-SP5, SP5-Water, and Water-Water correlations
    ofile_SS = open(sprefix+'-II-real.dat',"ab")  # SP5-SP5
    ofile_SW = open(sprefix+'-IW-real.dat',"ab")  # SP5-Water
    ofile_WW = open(sprefix+'-WW-real.dat',"ab")  # Water-Water

    nframe = 0
    while True:
        start_time = time.time()
        # read frame
        try:
            [ cell, types, sq] = read_lammpstrj(traj)
        except:
            break
        nframe += 1
        print("Frame No:", nframe)

        if (nframe == 1):
            # normalization
            volume = np.prod(cell[:])

            kgrid = np.zeros((bins*bins*bins,3),float)
            kgridbase = np.zeros((bins*bins*bins,3),float)
            # initialize k grid
            [ dkx, dky, dkz ] = [ 1./cell[0], 1./cell[1], 1./cell[2] ]
            n=0
            for i in range(bins):
                for j in range(bins):
                    for k in range(bins):
                        if i+j+k == 0: pass
                        # initialize k grid
                        kgridbase[n,:] = (2.*pi)*np.array([i, j, k])
                        kgrid[n,:] = [ dkx*i, dky*j, dkz*k ]
                        n+=1
            np.savetxt(sprefix+'-kgrid.dat',kgrid)

        print("--- %s seconds after read frame ---" % (time.time() - start_time))
        # FT analysis of density fluctuations
        sk_SS, sk_SW, sk_WW = Sk(types, sq, kgridbase)
        print("--- %s seconds after FFT density ---" % (time.time() - start_time))

        # Outputs
        np.savetxt(ofile_SS,sk_SS[None].real, fmt='%4.4e', delimiter=' ',header="Frame No: "+str(nframe))
        np.savetxt(ofile_SW,sk_SW[None].real, fmt='%4.4e', delimiter=' ',header="Frame No: "+str(nframe))
        np.savetxt(ofile_WW,sk_WW[None].real, fmt='%4.4e', delimiter=' ',header="Frame No: "+str(nframe))

    print("A total of data points ", nframe)
    sys.exit()

if __name__ == '__main__':
    main(*sys.argv[1:]) 