C        Generated by TAPENADE     (INRIA, Ecuador team)
C  Tapenade 3.16 (develop) - 15 Jan 2021 14:26
C
C  Differentiation of get_res in reverse (adjoint) mode (with options i4 dr8 r8):
C   gradient     of useful results: res
C   with respect to varying inputs: alfa rv1 rv2 rc chordv enc
C                res
C   RW status of diff variables: alfa:out rv1:out rv2:out rc:out
C                chordv:out enc:out res:in-zero
Csubroutine solve_rhs
      SUBROUTINE GET_RES_B()
      INCLUDE 'AVL.INC'
      INCLUDE 'AVL_ad_seeds.inc'
      INTEGER i
      INTEGER ii1
      INTEGER branch
      INTEGER ii2
C---  
      IF (.NOT.laic) THEN
        CALL PUSHREAL8ARRAY(wc_gam, 3*nvmax**2)
        CALL BUILD_AIC()
        CALL PUSHCONTROL1B(0)
      ELSE
        CALL PUSHCONTROL1B(1)
      END IF
C---- set VINF() vector from initial ALFA,BETA
      CALL VINFAB()
C
      DO ii1=1,nvmax
        rhs_diff(ii1) = 0.D0
      ENDDO
      DO i=nvor,1,-1
        rhs_diff(i) = rhs_diff(i) - res_diff(i)
      ENDDO
      CALL MAT_PROD_B(aicn, aicn_diff, gam, nvor, res, res_diff)
      DO ii1=1,6000
        res_diff(ii1) = 0.D0
      ENDDO
      CALL SET_VEL_RHS_B()
      CALL VINFAB_B()
      CALL POPCONTROL1B(branch)
      IF (.TRUE.) THEN
        ! CALL POPREAL8ARRAY(wc_gam, 3*nvmax**2)
        CALL BUILD_AIC_B()
      ELSE
        DO ii1=1,nvmax
          DO ii2=1,3
            rv1_diff(ii2, ii1) = 0.D0
          ENDDO
        ENDDO
        DO ii1=1,nvmax
          DO ii2=1,3
            rv2_diff(ii2, ii1) = 0.D0
          ENDDO
        ENDDO
        DO ii1=1,nvmax
          chordv_diff(ii1) = 0.D0
        ENDDO
      END IF
      END

