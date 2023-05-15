C        Generated by TAPENADE     (INRIA, Ecuador team)
C  Tapenade 3.16 (develop) - 15 Jan 2021 14:26
C
C  Differentiation of build_aic in forward (tangent) mode (with options i4 dr8 r8):
C   variations   of useful results: aicn
C   with respect to varying inputs: ysym zsym mach rv1 rv2 rc chordv
C                enc
C SETUP
C
C
      SUBROUTINE BUILD_AIC_D()
      INCLUDE 'AVL.INC'
      INCLUDE 'AVL_ad_seeds.inc'
      REAL betm
      REAL betm_diff
      INTRINSIC SQRT
      INTEGER i
      INTEGER j
      INTEGER n
      INTEGER j1
      INTEGER jn
      INTEGER i1
      INTEGER iv
      INTEGER jv
      REAL(kind=8) arg1
      REAL(kind=8) arg1_diff
      REAL(kind=avl_real) temp
      INTEGER ii2
      INTEGER ii1
      amach_diff = mach_diff
      amach = mach
      arg1_diff = -(2*amach*amach_diff)
      arg1 = 1.0 - amach**2
      temp = SQRT(arg1)
      IF (arg1 .EQ. 0.D0) THEN
        betm_diff = 0.D0
      ELSE
        betm_diff = arg1_diff/(2.0*temp)
      END IF
      betm = temp
      IF (lverbose) WRITE(*, *) ' Building normalwash AIC matrix...'
      CALL VVOR_D(betm, betm_diff, iysym, ysym, ysym_diff, izsym, zsym, 
     +            zsym_diff, vrcore, nvor, rv1, rv1_diff, rv2, rv2_diff
     +            , nsurfv, chordv, chordv_diff, nvor, rc, rc_diff, 
     +            nsurfv, .false., wc_gam, wc_gam_diff, nvmax)
      DO ii1=1,nvmax
        DO ii2=1,nvmax
          aicn_diff(ii2, ii1) = 0.D0
        ENDDO
      ENDDO
      DO i=1,nvor
        DO j=1,nvor
          aicn_diff(i, j) = enc(1, i)*wc_gam_diff(1, i, j) + wc_gam(1, i
     +      , j)*enc_diff(1, i) + enc(2, i)*wc_gam_diff(2, i, j) + 
     +      wc_gam(2, i, j)*enc_diff(2, i) + enc(3, i)*wc_gam_diff(3, i
     +      , j) + wc_gam(3, i, j)*enc_diff(3, i)
          aicn(i, j) = wc_gam(1, i, j)*enc(1, i) + wc_gam(2, i, j)*enc(2
     +      , i) + wc_gam(3, i, j)*enc(3, i)
          lvnc(i) = .true.
        ENDDO
      ENDDO
C
C----- process each surface which does not shed a wake
      DO n=1,nsurf
        IF (.NOT.lfwake(n)) THEN
C
C------- go over TE control points on this surface
          j1 = jfrst(n)
          jn = jfrst(n) + nj(n) - 1
C
          DO j=j1,jn
            i1 = ijfrst(j)
            iv = ijfrst(j) + nvstrp(j) - 1
C
C--------- clear system row for TE control point
            DO jv=1,nvor
              aicn_diff(iv, jv) = 0.D0
              aicn(iv, jv) = 0.
            ENDDO
            lvnc(iv) = .false.
C
C--------- set  sum_strip(Gamma) = 0  for this strip
            DO jv=i1,iv
              aicn_diff(iv, jv) = 0.D0
              aicn(iv, jv) = 1.0
            ENDDO
          ENDDO
        END IF
      ENDDO
      END

C  Differentiation of velsum in forward (tangent) mode (with options i4 dr8 r8):
C   variations   of useful results: wv
C   with respect to varying inputs: vinf wrot gam
C   RW status of diff variables: vinf:in wrot:in gam:in wv:out
C GAMSUM
C
C
      SUBROUTINE VELSUM_D()
      INCLUDE 'AVL.INC'
      INCLUDE 'AVL_ad_seeds.inc'
      INTEGER i
      INTEGER k
      INTEGER j
      INTEGER n
      INTEGER ii2
      INTEGER ii1
      DO ii1=1,nvmax
        DO ii2=1,3
          wv_diff(ii2, ii1) = 0.D0
        ENDDO
      ENDDO
C--------------------------------------------------
C     Sums AIC components to get WC, WV
C--------------------------------------------------
C
C
      DO i=1,nvor
        DO k=1,3
          wc(k, i) = wcsrd_u(k, i, 1)*vinf(1) + wcsrd_u(k, i, 2)*vinf(2)
     +      + wcsrd_u(k, i, 3)*vinf(3) + wcsrd_u(k, i, 4)*wrot(1) + 
     +      wcsrd_u(k, i, 5)*wrot(2) + wcsrd_u(k, i, 6)*wrot(3)
          wv_diff(k, i) = wvsrd_u(k, i, 1)*vinf_diff(1) + wvsrd_u(k, i, 
     +      2)*vinf_diff(2) + wvsrd_u(k, i, 3)*vinf_diff(3) + wvsrd_u(k
     +      , i, 4)*wrot_diff(1) + wvsrd_u(k, i, 5)*wrot_diff(2) + 
     +      wvsrd_u(k, i, 6)*wrot_diff(3)
          wv(k, i) = wvsrd_u(k, i, 1)*vinf(1) + wvsrd_u(k, i, 2)*vinf(2)
     +      + wvsrd_u(k, i, 3)*vinf(3) + wvsrd_u(k, i, 4)*wrot(1) + 
     +      wvsrd_u(k, i, 5)*wrot(2) + wvsrd_u(k, i, 6)*wrot(3)
        ENDDO
      ENDDO
      DO j=1,nvor
        DO i=1,nvor
          DO k=1,3
            wc(k, i) = wc(k, i) + wc_gam(k, i, j)*gam(j)
            wv_diff(k, i) = wv_diff(k, i) + wv_gam(k, i, j)*gam_diff(j)
            wv(k, i) = wv(k, i) + wv_gam(k, i, j)*gam(j)
          ENDDO
        ENDDO
      ENDDO
      DO n=1,numax
        DO i=1,nvor
          DO k=1,3
            wc_u(k, i, n) = wcsrd_u(k, i, n)
            wv_u(k, i, n) = wvsrd_u(k, i, n)
          ENDDO
        ENDDO
      ENDDO
      DO n=1,numax
        DO j=1,nvor
          DO i=1,nvor
            DO k=1,3
              wc_u(k, i, n) = wc_u(k, i, n) + wc_gam(k, i, j)*gam_u(j, n
     +          )
              wv_u(k, i, n) = wv_u(k, i, n) + wv_gam(k, i, j)*gam_u(j, n
     +          )
            ENDDO
          ENDDO
        ENDDO
      ENDDO
C
C
      RETURN
      END

C  Differentiation of set_vel_rhs in forward (tangent) mode (with options i4 dr8 r8):
C   variations   of useful results: rhs
C   with respect to varying inputs: vinf xyzref rc enc
      SUBROUTINE SET_VEL_RHS_D()
C
      INCLUDE 'AVL.INC'
      INCLUDE 'AVL_ad_seeds.inc'
      REAL rrot(3), vunit(3), vunit_w_term(3), wunit(3)
      REAL rrot_diff(3), vunit_diff(3), vunit_w_term_diff(3), wunit_diff
     +     (3)
      INTEGER i
      REAL DOT
      REAL DOT_D
      REAL result1
      REAL result1_diff
      rhs_diff = 0.D0
      vunit_diff = 0.D0
      vunit_w_term_diff = 0.D0
      rrot_diff = 0.D0
      DO i=1,nvor
        IF (lvnc(i)) THEN
          vunit_diff(1) = 0.D0
          vunit(1) = 0.
          vunit_diff(2) = 0.D0
          vunit(2) = 0.
          vunit_diff(3) = 0.D0
          vunit(3) = 0.
          wunit(1) = 0.
          wunit(2) = 0.
          wunit(3) = 0.
          IF (lvalbe(i)) THEN
            vunit_diff(1) = vinf_diff(1)
            vunit(1) = vinf(1)
            vunit_diff(2) = vinf_diff(2)
            vunit(2) = vinf(2)
            vunit_diff(3) = vinf_diff(3)
            vunit(3) = vinf(3)
            wunit(1) = wrot(1)
            wunit(2) = wrot(2)
            wunit(3) = wrot(3)
          END IF
          rrot_diff(1) = rc_diff(1, i) - xyzref_diff(1)
          rrot(1) = rc(1, i) - xyzref(1)
          rrot_diff(2) = rc_diff(2, i) - xyzref_diff(2)
          rrot(2) = rc(2, i) - xyzref(2)
          rrot_diff(3) = rc_diff(3, i) - xyzref_diff(3)
          rrot(3) = rc(3, i) - xyzref(3)
          wunit_diff = 0.D0
          CALL CROSS_D(rrot, rrot_diff, wunit, wunit_diff, vunit_w_term
     +                 , vunit_w_term_diff)
          vunit_diff = vunit_diff + vunit_w_term_diff
          vunit = vunit + vunit_w_term
          result1_diff = DOT_D(enc(1, i), enc_diff(1, i), vunit, 
     +      vunit_diff, result1)
          rhs_diff(i) = -result1_diff
          rhs(i) = -result1
        ELSE
          rhs_diff(i) = 0.D0
          rhs(i) = 0
        END IF
      ENDDO
      END

C  Differentiation of mat_prod in forward (tangent) mode (with options i4 dr8 r8):
C   variations   of useful results: out_vec
C   with respect to varying inputs: vec mat
Cset_vel_rhs
      SUBROUTINE MAT_PROD_D(mat, mat_diff, vec, vec_diff, n, out_vec, 
     +                      out_vec_diff)
      INCLUDE 'AVL.INC'
      INCLUDE 'AVL_ad_seeds.inc'
      REAL mat(nvmax, nvmax), vec(nvmax), out_vec(nvmax)
      REAL mat_diff(nvmax, nvmax), vec_diff(nvmax), out_vec_diff(nvmax)
      INTEGER j
      INTEGER i
      INTEGER n
      out_vec = 0.
      out_vec_diff = 0.D0
      DO j=1,n
        DO i=1,n
          out_vec_diff(i) = out_vec_diff(i) + vec(j)*mat_diff(i, j) + 
     +      mat(i, j)*vec_diff(j)
          out_vec(i) = out_vec(i) + mat(i, j)*vec(j)
        ENDDO
      ENDDO
      END
Cmat_prod

