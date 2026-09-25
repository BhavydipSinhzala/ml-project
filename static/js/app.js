/**
 * FinRisk AI — Loan Default Prediction System Frontend Engine
 * Modern UI Interactions & Backend API Integration
 * Note: Preserves 100% backend API contracts and prediction data flow.
 */
document.addEventListener('DOMContentLoaded', () => {

    // ---- Mobile Navigation Toggle ----
    const menuToggle = document.querySelector('.menu-toggle');
    const navLinks = document.querySelector('.nav-links');
    if (menuToggle && navLinks) {
        menuToggle.addEventListener('click', () => navLinks.classList.toggle('open'));
    }

    // ---- Toast Notification System ----
    function showToast(msg, type = 'info', duration = 3500) {
        let c = document.getElementById('toast-container');
        if (!c) {
            c = document.createElement('div');
            c.className = 'toast-container';
            c.id = 'toast-container';
            document.body.appendChild(c);
        }
        const t = document.createElement('div');
        t.className = `toast toast-${type}`;
        
        // Add SVG icon to toast
        let iconSvg = '';
        if (type === 'success') {
            iconSvg = `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>`;
        } else if (type === 'error') {
            iconSvg = `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>`;
        } else {
            iconSvg = `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>`;
        }
        
        t.innerHTML = `${iconSvg}<span>${msg}</span>`;
        c.appendChild(t);
        
        setTimeout(() => {
            t.style.opacity = '0';
            t.style.transform = 'translateX(30px)';
            setTimeout(() => t.remove(), 250);
        }, duration);
    }

    // ---- Loading Overlay Control ----
    function showLoading(msg = 'Running Gradient Boosting Risk Assessment...') {
        const o = document.getElementById('loading-overlay');
        const txt = document.getElementById('loading-text-msg');
        if (txt) txt.textContent = msg;
        if (o) o.classList.remove('hidden');
    }

    function hideLoading() {
        const o = document.getElementById('loading-overlay');
        if (o) o.classList.add('hidden');
    }

    // ---- Formatting Helper ----
    function fmtPct(v) {
        if (v == null || isNaN(v)) return 'N/A';
        var n = parseFloat(v);
        return n <= 1 ? (n * 100).toFixed(2) + '%' : n.toFixed(2) + '%';
    }

    // ---- HOME PAGE LOGIC ----
    const statAcc = document.getElementById('stat-accuracy');
    if (statAcc) {
        fetch('/api/health')
            .then(r => r.json())
            .then(d => {
                if (d.accuracy != null) statAcc.textContent = fmtPct(d.accuracy);
            })
            .catch(() => {});
    }

    // ---- PREDICTION PAGE LOGIC ----
    const form = document.getElementById('predict-form');
    if (form) {
        let presets = {};
        
        // Fetch Sample Data Presets
        fetch('/api/default-applicant')
            .then(r => r.json())
            .then(d => { presets = d; })
            .catch(() => {});

        document.querySelectorAll('.preset-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                const key = btn.dataset.preset;
                if (presets[key]) {
                    fillForm(presets[key]);
                    showToast(`Loaded ${presets[key].name || key} preset profile`, 'info');
                    document.querySelectorAll('.preset-btn').forEach(b => b.classList.remove('active'));
                    btn.classList.add('active');
                }
            });
        });

        function fillForm(d) {
            if (!d) return;
            ['age','income','loanAmount','creditScore','monthsEmployed','numCreditLines','interestRate','dtiRatio'].forEach(k => {
                const el = document.getElementById(k);
                if (el && d[k] !== undefined) el.value = d[k];
            });
            ['education','employmentType','maritalStatus','loanTerm','loanPurpose'].forEach(k => {
                const el = document.getElementById(k);
                if (el && d[k] !== undefined) el.value = String(d[k]);
            });
            ['hasMortgage','hasDependents','hasCoSigner'].forEach(k => {
                const el = document.getElementById(k);
                if (el && d[k] !== undefined) el.checked = !!d[k];
            });
            document.querySelectorAll('.form-group.error').forEach(g => g.classList.remove('error'));
        }

        function validate() {
            let ok = true;
            document.querySelectorAll('.form-group.error').forEach(g => g.classList.remove('error'));
            
            const rules = [
                {id:'age', min:18, max:69, int:true},
                {id:'income', min:15000, max:150000},
                {id:'loanAmount', min:5000, max:250000},
                {id:'creditScore', min:300, max:850, int:true},
                {id:'monthsEmployed', min:0, max:120, int:true},
                {id:'numCreditLines', min:1, max:4, int:true},
                {id:'interestRate', min:2, max:25},
                {id:'dtiRatio', min:0.1, max:0.9}
            ];

            rules.forEach(r => {
                const el = document.getElementById(r.id);
                if (!el) return;
                const v = parseFloat(el.value);
                const g = el.closest('.form-group');
                if (el.value.trim()==='' || isNaN(v) || v<r.min || v>r.max || (r.int && !Number.isInteger(v))) {
                    if (g) g.classList.add('error');
                    ok = false;
                }
            });
            return ok;
        }

        form.addEventListener('submit', async (e) => {
            e.preventDefault();
            if (!validate()) {
                showToast('Please correct the highlighted form errors.', 'error');
                return;
            }

            const payload = {
                age: parseInt(document.getElementById('age').value),
                income: parseFloat(document.getElementById('income').value),
                loanAmount: parseFloat(document.getElementById('loanAmount').value),
                creditScore: parseInt(document.getElementById('creditScore').value),
                monthsEmployed: parseInt(document.getElementById('monthsEmployed').value),
                numCreditLines: parseInt(document.getElementById('numCreditLines').value),
                interestRate: parseFloat(document.getElementById('interestRate').value),
                loanTerm: parseInt(document.getElementById('loanTerm').value),
                dtiRatio: parseFloat(document.getElementById('dtiRatio').value),
                education: document.getElementById('education').value,
                employmentType: document.getElementById('employmentType').value,
                maritalStatus: document.getElementById('maritalStatus').value,
                loanPurpose: document.getElementById('loanPurpose').value,
                hasMortgage: document.getElementById('hasMortgage').checked,
                hasDependents: document.getElementById('hasDependents').checked,
                hasCoSigner: document.getElementById('hasCoSigner').checked
            };

            showLoading('Preprocessing financial attributes & running model...');

            try {
                const res = await fetch('/api/predict', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify(payload)
                });

                const data = await res.json();
                if (!res.ok || data.status !== 'success') {
                    throw new Error(data.message || 'Server error occurred during prediction');
                }

                showResult(data, payload);
                showToast('Risk prediction complete.', 'success');
            } catch (err) {
                showToast('Prediction Error: ' + err.message, 'error');
            } finally {
                hideLoading();
            }
        });

        function showResult(data, sent) {
            const sec = document.getElementById('result-section');
            if (!sec) return;
            
            sec.classList.remove('hidden');
            setTimeout(() => sec.scrollIntoView({behavior:'smooth', block:'start'}), 80);

            const isNoDefault = data.prediction_text === 'No';
            const banner = document.getElementById('result-banner');
            banner.className = 'result-banner ' + (isNoDefault ? 'success' : 'danger');

            const iconEl = document.getElementById('result-icon');
            if (isNoDefault) {
                iconEl.innerHTML = `<svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>`;
            } else {
                iconEl.innerHTML = `<svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>`;
            }

            document.getElementById('result-title').textContent = isNoDefault ? 
                'Default Prediction: Low Risk (No Default)' : 
                'Default Prediction: High Risk (Potential Default)';
            
            document.getElementById('result-subtitle').textContent = isNoDefault ?
                'The Gradient Boosting model predicts this applicant is highly likely to meet repayment obligations.' :
                'The Gradient Boosting model flags this applicant profile as having elevated default risk.';

            const predEl = document.getElementById('result-prediction');
            predEl.textContent = isNoDefault ? 'No Default (0)' : 'Default (1)';
            predEl.style.color = isNoDefault ? 'var(--success)' : 'var(--danger)';

            document.getElementById('result-probability').textContent = data.default_probability.toFixed(2) + '%';
            
            const bar = document.getElementById('result-probability-bar');
            bar.style.width = Math.min(data.default_probability, 100) + '%';
            bar.style.backgroundColor = data.default_probability > 50 ? 'var(--danger)' : (data.default_probability > 20 ? 'var(--warning)' : 'var(--success)');

            document.getElementById('result-risk-tier').textContent = data.risk_tier;

            // Render Positive Factors
            const posList = document.getElementById('positive-factors');
            posList.innerHTML = '';
            if (data.positive_factors && data.positive_factors.length) {
                data.positive_factors.forEach(f => {
                    const li = document.createElement('li');
                    li.className = 'pos';
                    li.innerHTML = `<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg><span>${f}</span>`;
                    posList.appendChild(li);
                });
            } else {
                posList.innerHTML = `<li style="color: var(--text-muted);">No prominent positive factors identified</li>`;
            }

            // Render Risk Factors
            const riskList = document.getElementById('risk-factors');
            riskList.innerHTML = '';
            if (data.risk_factors && data.risk_factors.length) {
                data.risk_factors.forEach(f => {
                    const li = document.createElement('li');
                    li.className = 'neg';
                    li.innerHTML = `<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg><span>${f}</span>`;
                    riskList.appendChild(li);
                });
            } else {
                riskList.innerHTML = `<li style="color: var(--text-muted);">No major risk factors identified</li>`;
            }

            // Render Summary Data Table
            const summ = document.getElementById('applicant-summary');
            if (summ && sent) {
                const labels = {
                    age: 'Age', income: 'Annual Income', loanAmount: 'Loan Amount',
                    creditScore: 'Credit Score', monthsEmployed: 'Months Employed',
                    numCreditLines: 'Credit Lines', interestRate: 'Interest Rate',
                    loanTerm: 'Loan Term', dtiRatio: 'DTI Ratio',
                    education: 'Education', employmentType: 'Employment Type',
                    maritalStatus: 'Marital Status', loanPurpose: 'Loan Purpose',
                    hasMortgage: 'Has Mortgage', hasDependents: 'Has Dependents', hasCoSigner: 'Has Co-Signer'
                };

                const fmtVal = (k, v) => {
                    if (typeof v === 'boolean') return v ? 'Yes' : 'No';
                    if (k === 'income' || k === 'loanAmount') return '$' + Number(v).toLocaleString();
                    if (k === 'interestRate') return v + '%';
                    if (k === 'loanTerm') return v + ' Months';
                    return v;
                };

                let rows = '';
                for (const [k, lbl] of Object.entries(labels)) {
                    if (sent[k] !== undefined) {
                        rows += `<tr><th>${lbl}</th><td>${fmtVal(k, sent[k])}</td></tr>`;
                    }
                }
                summ.innerHTML = `<table class="summary-table">${rows}</table>`;
            }
        }

        const resetBtn = document.getElementById('reset-btn');
        if (resetBtn) {
            resetBtn.addEventListener('click', () => {
                document.getElementById('result-section').classList.add('hidden');
                form.scrollIntoView({behavior:'smooth'});
            });
        }
    }

    // ---- MODELS PAGE LOGIC ----
    const metricsTable = document.getElementById('metrics-table');
    if (metricsTable) {
        fetch('/api/models')
            .then(r => r.json())
            .then(data => {
                const descEl = document.getElementById('model-description');
                if (descEl) descEl.textContent = data.description || '';

                const tbody = metricsTable.querySelector('tbody');
                tbody.innerHTML = '';

                const metrics = [
                    ['Accuracy', data.accuracy],
                    ['Precision', data.precision],
                    ['Recall', data.recall],
                    ['F1-Score', data.f1_score],
                    ['ROC-AUC', data.roc_auc],
                    ['CV Mean Accuracy', data.cv_mean_accuracy]
                ];

                metrics.forEach(([label, val]) => {
                    const tr = document.createElement('tr');
                    tr.innerHTML = `<td><strong>${label}</strong></td><td>${fmtPct(val)}</td>`;
                    tbody.appendChild(tr);
                });

                const cm = data.confusion_matrix;
                if (cm) {
                    const cmCard = document.getElementById('cm-card');
                    const cmTable = document.getElementById('cm-table');
                    if (cmCard && cmTable) {
                        cmCard.style.display = 'block';
                        cmTable.innerHTML = `
                            <tr>
                                <th></th>
                                <th>Predicted Non-Default (0)</th>
                                <th>Predicted Default (1)</th>
                            </tr>
                            <tr>
                                <th>Actual Non-Default (0)</th>
                                <td class="tn">TN: ${cm.tn.toLocaleString()}</td>
                                <td class="fp">FP: ${cm.fp.toLocaleString()}</td>
                            </tr>
                            <tr>
                                <th>Actual Default (1)</th>
                                <td class="fn">FN: ${cm.fn.toLocaleString()}</td>
                                <td class="tp">TP: ${cm.tp.toLocaleString()}</td>
                            </tr>
                        `;
                    }
                }
            })
            .catch(() => {
                const tbody = metricsTable.querySelector('tbody');
                if (tbody) tbody.innerHTML = `<tr><td colspan="2" style="color:var(--danger)">Failed to fetch model metrics. Verify Flask backend status.</td></tr>`;
            });
    }
});
