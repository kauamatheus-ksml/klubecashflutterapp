#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de Teste dos Endpoints da API Klube Cash
Testa todos os endpoints para verificar disponibilidade e estrutura de resposta
"""

import requests
import json
import time
from datetime import datetime
from typing import Dict, List, Optional, Tuple

class KlubeCashAPITester:
    def __init__(self):
        self.base_url = "https://klubecash.com/api"
        self.session = requests.Session()
        self.session.headers.update({
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'User-Agent': 'KlubeCashAPITester/1.0'
        })
        self.auth_token = None
        self.test_results = []
        
    def log_test(self, endpoint: str, method: str, status_code: int, 
                 response_data: dict, error: Optional[str] = None, 
                 success: bool = True):
        """Registra resultado de um teste"""
        result = {
            'timestamp': datetime.now().isoformat(),
            'endpoint': endpoint,
            'method': method,
            'status_code': status_code,
            'success': success,
            'response_data': response_data,
            'error': error
        }
        self.test_results.append(result)
        
        # Log imediato
        status = "✅ SUCESSO" if success else "❌ ERRO"
        print(f"{status} | {method} {endpoint} | {status_code} | {error or 'OK'}")
        
    def test_endpoint(self, endpoint: str, method: str = 'GET', 
                     data: dict = None, use_auth: bool = False) -> Tuple[bool, dict, str]:
        """Testa um endpoint específico"""
        url = f"{self.base_url}/{endpoint}"
        headers = self.session.headers.copy()
        
        if use_auth and self.auth_token:
            headers['Authorization'] = f'Bearer {self.auth_token}'
            
        try:
            if method == 'GET':
                response = self.session.get(url, headers=headers, timeout=30)
            elif method == 'POST':
                response = self.session.post(url, headers=headers, 
                                           data=json.dumps(data) if data else None, timeout=30)
            elif method == 'PUT':
                response = self.session.put(url, headers=headers, 
                                          data=json.dumps(data) if data else None, timeout=30)
            else:
                return False, {}, f"Método {method} não suportado"
                
            try:
                response_data = response.json()
            except:
                response_data = {'raw_response': response.text[:500]}
                
            success = response.status_code in [200, 201]
            error = None if success else f"HTTP {response.status_code}"
            
            self.log_test(endpoint, method, response.status_code, 
                         response_data, error, success)
            
            return success, response_data, error or "OK"
            
        except requests.exceptions.Timeout:
            error = "Timeout (30s)"
            self.log_test(endpoint, method, 0, {}, error, False)
            return False, {}, error
            
        except requests.exceptions.ConnectionError:
            error = "Erro de conexão"
            self.log_test(endpoint, method, 0, {}, error, False)
            return False, {}, error
            
        except Exception as e:
            error = f"Erro inesperado: {str(e)}"
            self.log_test(endpoint, method, 0, {}, error, False)
            return False, {}, error

    def test_login(self) -> bool:
        """Testa endpoint de login e obtém token"""
        print("\n🔐 TESTANDO AUTENTICAÇÃO...")
        
        # Dados de teste para login
        test_credentials = [
            {"email": "admin@klubecash.com", "senha": "123456"},
            {"email": "teste@klubecash.com", "senha": "123456"},
            {"email": "user@test.com", "senha": "password"},
        ]
        
        for cred in test_credentials:
            print(f"\n   Tentando login com: {cred['email']}")
            success, response, error = self.test_endpoint('login.php', 'POST', cred)
            
            if success and response.get('status') and response.get('token'):
                self.auth_token = response['token']
                print(f"   ✅ Token obtido: {self.auth_token[:20]}...")
                return True
            elif success:
                print(f"   ⚠️  Login retornou: {response}")
            else:
                print(f"   ❌ Falha: {error}")
                
        print("   ⚠️  Nenhum login funcionou, continuando sem token...")
        return False

    def test_registration(self):
        """Testa endpoint de registro"""
        print("\n📝 TESTANDO REGISTRO...")
        
        test_data = {
            "nome": "Usuário Teste API",
            "email": f"teste_api_{int(time.time())}@klubecash.com",
            "telefone": "(11) 99999-9999",
            "senha": "123456789",
            "tipo": "cliente"
        }
        
        self.test_endpoint('register.php', 'POST', test_data)

    def test_user_balance(self):
        """Testa endpoint de saldo do usuário"""
        print("\n💰 TESTANDO SALDO DO USUÁRIO...")
        self.test_endpoint('user-balance.php', 'GET', use_auth=True)

    def test_transactions(self):
        """Testa endpoint de transações"""
        print("\n📊 TESTANDO TRANSAÇÕES...")
        
        # Teste sem parâmetros
        self.test_endpoint('transactions.php', 'GET', use_auth=True)
        
        # Teste com parâmetros
        self.test_endpoint('transactions.php?limit=10&offset=0', 'GET', use_auth=True)

    def test_stores(self):
        """Testa endpoints de lojas"""
        print("\n🏪 TESTANDO LOJAS...")
        
        # Teste lojas gerais
        self.test_endpoint('stores.php', 'GET', use_auth=True)
        
        # Teste com limite
        self.test_endpoint('stores.php?limit=5', 'GET', use_auth=True)

    def test_store_balances(self):
        """Testa endpoint de saldos por loja"""
        print("\n🏦 TESTANDO SALDOS POR LOJA...")
        self.test_endpoint('store-balances.php', 'GET', use_auth=True)

    def test_profile(self):
        """Testa endpoints de perfil"""
        print("\n👤 TESTANDO PERFIL...")
        
        # GET perfil
        success, profile_data, error = self.test_endpoint('profile.php', 'GET', use_auth=True)
        
        # PUT perfil (atualização)
        if success and profile_data.get('data'):
            update_data = profile_data['data'].copy()
            update_data['nome'] = f"Nome Atualizado {int(time.time())}"
            self.test_endpoint('profile.php', 'PUT', update_data, use_auth=True)

    def test_password_recovery(self):
        """Testa endpoints de recuperação de senha"""
        print("\n🔑 TESTANDO RECUPERAÇÃO DE SENHA...")
        
        # Solicitar recuperação
        recovery_data = {"email": "teste@klubecash.com"}
        self.test_endpoint('recover-password.php', 'POST', recovery_data)
        
        # Teste reset (com token fictício)
        reset_data = {
            "token": "token_ficticio_para_teste",
            "newPassword": "nova_senha_123"
        }
        self.test_endpoint('reset-password.php', 'POST', reset_data)

    def test_change_password(self):
        """Testa mudança de senha"""
        print("\n🔐 TESTANDO MUDANÇA DE SENHA...")
        
        change_data = {
            "currentPassword": "123456",
            "newPassword": "nova_senha_789"
        }
        self.test_endpoint('change-password.php', 'POST', change_data, use_auth=True)

    def test_additional_endpoints(self):
        """Testa endpoints adicionais que podem existir"""
        print("\n🔍 TESTANDO ENDPOINTS ADICIONAIS...")
        
        additional_endpoints = [
            'users.php',
            'client.php',
            'commissions.php',
            'payments.php',
            'dashboard.php',
            'stores.php?action=popular',
            'users.php?action=login',
            'client.php?action=balance',
            'client.php?action=profile',
            'client.php?action=store_balances',
        ]
        
        for endpoint in additional_endpoints:
            print(f"   Testando: {endpoint}")
            self.test_endpoint(endpoint, 'GET', use_auth=True)

    def run_all_tests(self):
        """Executa todos os testes"""
        print("🚀 INICIANDO TESTE COMPLETO DA API KLUBE CASH")
        print("=" * 60)
        
        start_time = time.time()
        
        # 1. Teste de conectividade básica
        print("\n🌐 TESTANDO CONECTIVIDADE BÁSICA...")
        self.test_endpoint('', 'GET')  # Teste raiz
        
        # 2. Autenticação
        self.test_login()
        
        # 3. Registro
        self.test_registration()
        
        # 4. Endpoints autenticados
        if self.auth_token:
            self.test_user_balance()
            self.test_transactions()
            self.test_stores()
            self.test_store_balances()
            self.test_profile()
            self.test_change_password()
        else:
            print("\n⚠️  Pulando testes autenticados (sem token)")
            
        # 5. Recuperação de senha
        self.test_password_recovery()
        
        # 6. Endpoints adicionais
        self.test_additional_endpoints()
        
        # 7. Relatório final
        self.generate_report(time.time() - start_time)

    def generate_report(self, duration: float):
        """Gera relatório final dos testes"""
        print("\n" + "=" * 60)
        print("📊 RELATÓRIO FINAL DOS TESTES")
        print("=" * 60)
        
        total_tests = len(self.test_results)
        successful_tests = len([r for r in self.test_results if r['success']])
        failed_tests = total_tests - successful_tests
        
        print(f"⏱️  Duração total: {duration:.2f} segundos")
        print(f"📈 Total de testes: {total_tests}")
        print(f"✅ Sucessos: {successful_tests}")
        print(f"❌ Falhas: {failed_tests}")
        print(f"📊 Taxa de sucesso: {(successful_tests/total_tests)*100:.1f}%")
        
        print(f"\n🔑 Token obtido: {'Sim' if self.auth_token else 'Não'}")
        
        print("\n📋 RESUMO POR ENDPOINT:")
        print("-" * 60)
        
        endpoints_summary = {}
        for result in self.test_results:
            endpoint = result['endpoint']
            if endpoint not in endpoints_summary:
                endpoints_summary[endpoint] = {'success': 0, 'fail': 0, 'responses': []}
            
            if result['success']:
                endpoints_summary[endpoint]['success'] += 1
            else:
                endpoints_summary[endpoint]['fail'] += 1
                
            endpoints_summary[endpoint]['responses'].append(result)
        
        for endpoint, summary in endpoints_summary.items():
            status = "✅" if summary['fail'] == 0 else "❌" if summary['success'] == 0 else "⚠️"
            print(f"{status} {endpoint or 'ROOT'} | ✅{summary['success']} ❌{summary['fail']}")
            
            # Mostrar estrutura de resposta de sucesso
            for response in summary['responses']:
                if response['success'] and response['response_data']:
                    print(f"     Estrutura: {self.analyze_response_structure(response['response_data'])}")
                    break

        print("\n🔧 RECOMENDAÇÕES PARA O FLUTTER:")
        print("-" * 60)
        
        if successful_tests > 0:
            print("✅ API está respondendo - Flutter pode prosseguir")
            
            if self.auth_token:
                print("✅ Autenticação funcionando - usar Bearer token")
            else:
                print("⚠️  Verificar credenciais de login")
                
            # Analisar endpoints funcionais
            working_endpoints = [r['endpoint'] for r in self.test_results if r['success']]
            if working_endpoints:
                print("✅ Endpoints funcionais encontrados:")
                for endpoint in set(working_endpoints):
                    if endpoint:
                        print(f"   - {endpoint}")
        else:
            print("❌ API não está respondendo adequadamente")
            print("💡 Verificar:")
            print("   - Servidor https://klubecash.com está online?")
            print("   - Pasta /api existe?")
            print("   - Configurações de CORS?")
            print("   - Estrutura dos endpoints?")

        # Salvar relatório em arquivo
        self.save_report_to_file()

    def analyze_response_structure(self, response_data: dict) -> str:
        """Analisa estrutura da resposta"""
        if not isinstance(response_data, dict):
            return str(type(response_data).__name__)
            
        keys = list(response_data.keys())
        if len(keys) <= 3:
            return f"Keys: {keys}"
        else:
            return f"Keys: {keys[:3]}... (+{len(keys)-3} mais)"

    def save_report_to_file(self):
        """Salva relatório detalhado em arquivo JSON"""
        report_data = {
            'timestamp': datetime.now().isoformat(),
            'summary': {
                'total_tests': len(self.test_results),
                'successful_tests': len([r for r in self.test_results if r['success']]),
                'auth_token_obtained': bool(self.auth_token),
                'base_url': self.base_url
            },
            'detailed_results': self.test_results
        }
        
        filename = f"klube_cash_api_test_report_{int(time.time())}.json"
        
        try:
            with open(filename, 'w', encoding='utf-8') as f:
                json.dump(report_data, f, indent=2, ensure_ascii=False)
            print(f"\n💾 Relatório detalhado salvo em: {filename}")
        except Exception as e:
            print(f"\n❌ Erro ao salvar relatório: {e}")

def main():
    """Função principal"""
    print("🧪 KLUBE CASH API ENDPOINT TESTER")
    print("Testando todos os endpoints da API...")
    print()
    
    tester = KlubeCashAPITester()
    tester.run_all_tests()
    
    print("\n🎉 Teste concluído!")
    print("Verifique o relatório acima para ajustar o Flutter app.")

if __name__ == "__main__":
    main()