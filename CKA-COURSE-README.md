# 🎓 CKA Kubernetes Administrator Course

## Welcome to Your CKA Exam Preparation Journey!

This repository contains a **complete, hands-on CKA (Certified Kubernetes Administrator) exam preparation course** designed to make learning Kubernetes feel like a "cake walk" - clear, practical, and ready to use.

## 🚀 Quick Start

### New to This Course?

**Start Here**: [`course/00-overview.md`](course/00-overview.md)

This gives you:
- Course structure and learning paths
- Study schedule recommendations (2-12 weeks)
- Exam tips and success criteria
- Resource requirements

### Setting Up Your Lab

**Next Step**: [`course/01-lab-setup.md`](course/01-lab-setup.md)

Complete instructions for:
- Ubuntu 22.04 LTS setup
- RHEL/Rocky Linux 9 setup
- kubeadm cluster initialization
- Calico CNI installation

**Time**: 30-60 minutes for initial setup

## 📚 What You'll Learn

### Core Kubernetes Skills (12 Modules)

| Module | Topic | Time | Key Skills |
|--------|-------|------|------------|
| [00](course/00-overview.md) | Overview | 15 min | Course navigation, exam format |
| [01](course/01-lab-setup.md) | Lab Setup | 1 hour | Cluster installation, CNI |
| [02](course/02-cluster-architecture.md) | Architecture | 1 hour | Control plane, worker nodes |
| [03](course/03-installation-and-upgrade.md) | Install & Upgrade | 2 hours | Cluster lifecycle, etcd backup |
| [04](course/04-workloads-and-scheduling.md) | Workloads | 2 hours | Pods, Deployments, Jobs |
| [05](course/05-services-and-networking.md) | Networking | 2 hours | Services, Ingress, NetworkPolicies |
| [06](course/06-storage-and-state.md) | Storage | 1.5 hours | PV/PVC, StatefulSets |
| [07](course/07-rbac-and-security.md) | Security | 2 hours | RBAC, Pod Security |
| [08](course/08-observability-and-logging.md) | Observability | 1 hour | Logs, metrics, debugging |
| [09](course/09-cluster-maintenance.md) | Maintenance | 1.5 hours | Drain, etcd ops, upgrades |
| [10](course/10-troubleshooting-guide.md) | Troubleshooting | 2 hours | Systematic debugging |
| [11](course/11-exam-practice-drills.md) | Exam Prep | 2 hours | Timed drills, strategies |

**Total Learning Time**: 18-20 hours of focused study + practice

### Hands-On Project

**FoodCart Microservices Application** ([`project/README.md`](project/README.md))

Build a production-like app with:
- PostgreSQL StatefulSet
- Multiple microservices
- HorizontalPodAutoscaler
- NetworkPolicies
- Complete monitoring and troubleshooting

**Time**: 3-4 hours to deploy and understand

### Quick Reference Materials

- **YAML Examples**: [`course/yaml-examples/`](course/yaml-examples/) - 40 complete YAML files with 2-line descriptions
- **YAML Index**: [`course/YAML-EXAMPLES-INDEX.md`](course/YAML-EXAMPLES-INDEX.md) - Quick reference table of all examples
- **kubectl Cheatsheet**: [`cheatsheets/kubectl-cheatsheet.md`](cheatsheets/kubectl-cheatsheet.md) - 100+ commands
- **YAML Snippets**: [`cheatsheets/yaml-snippets.md`](cheatsheets/yaml-snippets.md) - Ready-to-use templates
- **Troubleshooting Guide**: [`cheatsheets/troubleshooting-checklist.md`](cheatsheets/troubleshooting-checklist.md) - Systematic debugging

### Practice Exams

Test your knowledge with realistic CKA-style exams:

- **Mock Exam 1**: [`exams/mock-exam-1.md`](exams/mock-exam-1.md) - 15 questions, 2 hours
- **Solutions**: [`exams/mock-exam-1-solutions.md`](exams/mock-exam-1-solutions.md)
- **Mock Exam 2**: [`exams/mock-exam-2.md`](exams/mock-exam-2.md) - 15 questions, 2 hours

**Passing Score**: 66% (aim for 90%+ before the real exam)

## 🎯 Learning Paths

### Fast Track (2-3 Weeks)
**Goal**: Pass CKA exam quickly

- **Week 1**: Modules 01-06, complete all mini-labs
- **Week 2**: Modules 07-09, build FoodCart project
- **Week 3**: Modules 10-11, take both mock exams until 90%+

**Daily commitment**: 2-3 hours

### Standard (4-6 Weeks)
**Goal**: Deep understanding + exam success

- **Weeks 1-2**: Modules 01-04, one module every 3-4 days
- **Weeks 3-4**: Modules 05-08, FoodCart project
- **Weeks 5-6**: Modules 09-11, troubleshooting focus, mock exams

**Daily commitment**: 1-2 hours

### Thorough (8-12 Weeks)
**Goal**: Master Kubernetes administration

- **One module per week** for deep learning
- **Multiple FoodCart deployments** with variations
- **Practice each exam drill** until perfect
- **Mock exams** repeated until consistent 95%+

**Daily commitment**: 30-60 minutes

## 🛠️ Prerequisites

### Required Knowledge
- Basic Linux command line (cd, ls, grep, systemctl)
- Understanding of containers (Docker basics)
- Familiarity with YAML syntax
- Text editor skills (vim or nano)

### Required Resources
- **3 Virtual Machines** or cloud instances:
  - 1 control plane: 2 vCPU, 2-4 GB RAM
  - 2 workers: 2 vCPU, 2 GB RAM each
- **OS**: Ubuntu 22.04 LTS or Rocky Linux 9
- **Internet access** for package installation
- **2-3 hours** for initial setup

### Recommended Tools
- Terminal multiplexer (tmux or screen)
- kubectl autocomplete configured
- Bookmark manager for Kubernetes docs

## 📖 Course Features

### ✅ What Makes This Course Different

1. **Commands First, Explanations Second**
   - Every concept starts with executable commands
   - Short, plain-English explanations follow
   - No jargon or unnecessary complexity

2. **Verification Built-In**
   - Every task includes "Verify" steps
   - Expected outputs shown clearly
   - Learn to confirm your work (critical for exam!)

3. **Danger Warnings**
   - Risky operations clearly marked
   - Safe alternatives provided
   - Learn what NOT to do in production

4. **Multi-Platform**
   - Ubuntu 22.04 LTS instructions
   - RHEL/Rocky Linux 9 alternatives
   - Works on VMs or cloud instances

5. **Exam-Aligned**
   - Covers 100% of CKA domains
   - Timed drills for speed building
   - Mock exams match real format

6. **Real-World Project**
   - Production-like microservices app
   - Complete SRE runbook included
   - Practice troubleshooting realistic scenarios

## 🎓 CKA Exam Information

### Exam Details
- **Duration**: 2 hours
- **Questions**: 15-20 performance-based tasks
- **Passing Score**: 66%
- **Format**: Remote proctored, browser-based terminal
- **Resources Allowed**: kubernetes.io documentation only
- **Cost**: $395 USD (includes one free retake)

### Exam Domains (2024)
- Cluster Architecture, Installation & Configuration (25%)
- Workloads & Scheduling (15%)
- Services & Networking (20%)
- Storage (10%)
- Troubleshooting (30%)

### After This Course, You'll Be Able To:
- [ ] Install a production-ready Kubernetes cluster
- [ ] Upgrade clusters across minor versions
- [ ] Configure RBAC for secure access control
- [ ] Troubleshoot any pod, service, or node issue
- [ ] Implement NetworkPolicies for security
- [ ] Manage persistent storage for stateful apps
- [ ] Backup and restore cluster state (etcd)
- [ ] Pass the CKA exam with confidence!

## 🤝 How to Use This Course

### For Individual Study
1. Fork this repository
2. Follow the learning path that fits your timeline
3. Complete all mini-labs and exercises
4. Build the FoodCart project
5. Take mock exams until you score 90%+
6. Schedule and ace your CKA exam!

### For Team Training
- Assign modules as weekly team exercises
- Review FoodCart project together
- Run mock exams as team competitions
- Share troubleshooting experiences

### For Instructors
- Use modules as lecture outlines
- Mini-labs work as classroom exercises
- FoodCart project perfect for capstone
- Mock exams for assessment

## 📞 Support & Resources

### Included in This Course
- 📚 12 comprehensive modules
- 💻 FoodCart hands-on project
- 📄 40 complete YAML examples with descriptions
- 📝 3 quick reference cheatsheets
- ✅ 2 complete mock exams with solutions
- 🔧 SRE troubleshooting runbook

### External Resources
- **Official Docs**: [kubernetes.io/docs](https://kubernetes.io/docs)
- **Practice Environment**: [killer.sh](https://killer.sh) (2 free sessions with exam purchase)
- **Community**: [Kubernetes Slack](https://kubernetes.slack.com)
- **Exam Info**: [CNCF CKA Page](https://www.cncf.io/certification/cka/)

### Getting Help
- Review the troubleshooting checklist
- Check module "Common Mistakes" sections
- Search kubernetes.io documentation
- Ask in Kubernetes community forums

## 🏆 Success Stories

Many students have used similar structured approaches to pass the CKA exam. Your success depends on:
- **Consistent practice** (better than cramming)
- **Hands-on labs** (reading isn't enough)
- **Timed practice** (build speed for the exam)
- **Real troubleshooting** (break things and fix them)

## 📅 Recommended Study Schedule

### Week-by-Week (Standard Path)

**Week 1**: Foundation
- Day 1-2: Module 00-01 (setup lab)
- Day 3-4: Module 02 (architecture)
- Day 5-7: Module 03 (installation/upgrade)

**Week 2**: Core Skills
- Day 1-2: Module 04 (workloads)
- Day 3-4: Module 05 (networking)
- Day 5-7: Module 06 (storage)

**Week 3**: Security & Operations
- Day 1-3: Module 07 (RBAC)
- Day 4-5: Module 08 (observability)
- Day 6-7: Start FoodCart project

**Week 4**: Project & Maintenance
- Day 1-3: Complete FoodCart project
- Day 4-7: Module 09 (maintenance)

**Week 5**: Troubleshooting
- Day 1-4: Module 10 (troubleshooting)
- Day 5-7: Module 11 (exam drills)

**Week 6**: Exam Prep
- Day 1-2: Mock Exam 1
- Day 3-4: Review mistakes, practice weak areas
- Day 5-6: Mock Exam 2
- Day 7: Final review, schedule exam

## 💡 Pro Tips

1. **Type every command** - Don't copy-paste during practice
2. **Use kubectl explain** - Learn to discover API fields
3. **Break things** - Practice troubleshooting by causing failures
4. **Time yourself** - Build speed with timed drills
5. **Document patterns** - Keep notes of commands you forget
6. **Practice context switching** - Critical skill for the exam
7. **Verify everything** - Get in the habit of checking your work

## 🎉 Ready to Start?

**Begin your journey**: [`course/00-overview.md`](course/00-overview.md)

Or jump straight to **lab setup**: [`course/01-lab-setup.md`](course/01-lab-setup.md)

---

**Good luck on your CKA exam! You've got this! 🚀**

---

*For detailed course overview and statistics, see [CKA-COURSE-SUMMARY.md](CKA-COURSE-SUMMARY.md)*
